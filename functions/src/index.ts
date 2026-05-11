import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging, type Message } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

type PreferenceKey = "notifyOnComment" | "notifyOnFollow" | "notifyOnLike";

interface PushArgs {
  recipientId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  preferenceKey?: PreferenceKey;
}

async function pushToUser(args: PushArgs): Promise<void> {
  const { recipientId, title, body, data = {}, preferenceKey } = args;

  const userRef = db.collection("users").doc(recipientId);
  const userSnap = await userRef.get();
  if (!userSnap.exists) {
    logger.info("Recipient missing", { recipientId });
    return;
  }
  const user = userSnap.data() ?? {};

  if (preferenceKey && user[preferenceKey] === false) {
    logger.info("Recipient opted out", { recipientId, preferenceKey });
    return;
  }

  const token = user.fcmToken as string | undefined;
  if (!token) {
    logger.info("Recipient has no fcmToken", { recipientId });
    return;
  }

  const message: Message = {
    token,
    notification: { title, body },
    data,
    android: {
      priority: "high",
      notification: { channelId: "meal_reminders" },
    },
    apns: {
      payload: { aps: { sound: "default", badge: 1 } },
    },
  };

  try {
    await messaging.send(message);
  } catch (err) {
    const code = (err as { code?: string }).code;
    logger.error("FCM send failed", { recipientId, code, err });
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      await userRef.update({ fcmToken: null });
    }
  }
}

// 1) New comment on a recipe -> push the recipe author
export const onCommentCreated = onDocumentCreated(
  "recipes/{recipeId}/comments/{commentId}",
  async (event) => {
    const comment = event.data?.data();
    if (!comment) return;
    if (comment.parentCommentId) return;

    const { recipeId, commentId } = event.params;

    const recipeSnap = await db.collection("recipes").doc(recipeId).get();
    if (!recipeSnap.exists) return;
    const recipe = recipeSnap.data() ?? {};

    const ownerId = recipe.authorId as string | undefined;
    const commenterId = comment.userId as string | undefined;
    if (!ownerId || !commenterId || ownerId === commenterId) return;

    const recipeTitle = (recipe.title as string | undefined) ?? "your recipe";
    const commenterName =
      (comment.authorName as string | undefined) ?? "Someone";
    const text = (comment.text as string | undefined) ?? "";

    await pushToUser({
      recipientId: ownerId,
      title: `New comment on "${recipeTitle}"`,
      body: `${commenterName}: ${text}`,
      data: { type: "comment", recipeId, commentId },
      preferenceKey: "notifyOnComment",
    });
  },
);

// 2) New follow -> push the followed user
export const onFollowCreated = onDocumentCreated(
  "follows/{followId}",
  async (event) => {
    const follow = event.data?.data();
    if (!follow) return;

    const followerId = follow.followerId as string | undefined;
    const followedId = follow.followedId as string | undefined;
    if (!followerId || !followedId || followerId === followedId) return;

    const followerSnap = await db.collection("users").doc(followerId).get();
    const followerData = followerSnap.data() ?? {};
    const followerName =
      ((followerData.fullName as string | undefined) ??
        `${followerData.firstName ?? ""} ${followerData.lastName ?? ""}`
          .trim()) ||
      "Someone";

    await pushToUser({
      recipientId: followedId,
      title: "New follower",
      body: `${followerName} started following you`,
      data: { type: "follow", followerId },
      preferenceKey: "notifyOnFollow",
    });
  },
);

// 3) New like -> push the recipe author
export const onLikeCreated = onDocumentCreated(
  "likes/{likeId}",
  async (event) => {
    const like = event.data?.data();
    if (!like) return;

    const recipeId = like.recipeId as string | undefined;
    const likerId = like.userId as string | undefined;
    if (!recipeId || !likerId) return;

    const [recipeSnap, likerSnap] = await Promise.all([
      db.collection("recipes").doc(recipeId).get(),
      db.collection("users").doc(likerId).get(),
    ]);
    if (!recipeSnap.exists) return;
    const recipe = recipeSnap.data() ?? {};

    const ownerId = recipe.authorId as string | undefined;
    if (!ownerId || ownerId === likerId) return;

    const likerData = likerSnap.data() ?? {};
    const likerName =
      ((likerData.fullName as string | undefined) ??
        `${likerData.firstName ?? ""} ${likerData.lastName ?? ""}`.trim()) ||
      "Someone";
    const recipeTitle = (recipe.title as string | undefined) ?? "your recipe";

    await pushToUser({
      recipientId: ownerId,
      title: "Someone liked your recipe",
      body: `${likerName} liked "${recipeTitle}"`,
      data: { type: "like", recipeId },
      preferenceKey: "notifyOnLike",
    });
  },
);

// 4) New public recipe -> broadcast to topic "new_recipes"
export const onRecipeCreated = onDocumentCreated(
  "recipes/{recipeId}",
  async (event) => {
    const recipe = event.data?.data();
    if (!recipe) return;
    if (recipe.isPrivate === true) return;

    const recipeId = event.params.recipeId;
    const title = (recipe.title as string | undefined) ?? "New recipe";
    const authorName =
      (recipe.authorName as string | undefined) ?? "a Chef Specials user";

    try {
      await messaging.send({
        topic: "new_recipes",
        notification: {
          title: "Fresh recipe to try",
          body: `${authorName} just shared "${title}"`,
        },
        data: { type: "newRecipe", recipeId },
        android: {
          priority: "high",
          notification: { channelId: "meal_reminders" },
        },
        apns: {
          payload: { aps: { sound: "default" } },
        },
      });
    } catch (err) {
      logger.error("Topic send failed", { err });
    }
  },
);
