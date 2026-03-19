import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/recipe_step.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/models/user_model.dart';
import 'package:chef_specials/models/food_item.dart';
import 'package:chef_specials/models/favorite.dart';
import 'package:chef_specials/models/rating.dart';
import 'package:chef_specials/models/comment.dart';
import 'package:chef_specials/models/daily_log.dart';
import 'package:chef_specials/models/meal_entry.dart';
import 'package:chef_specials/models/nutrition_goal.dart';
import 'package:chef_specials/models/shopping_list.dart';
import 'package:chef_specials/models/meal_plan.dart';
import 'package:chef_specials/models/planned_meal.dart';
import 'package:chef_specials/models/admin_log.dart';
import 'package:chef_specials/models/ban_appeal.dart';
import 'package:chef_specials/models/announcement.dart';

// ---------------------------------------------------------------------------
// Ingredient
// ---------------------------------------------------------------------------

Ingredient createTestIngredient({
  String? name,
  String? amount,
  String? unit,
  String? foodItemId,
  double? caloriesPer100,
  double? proteinPer100,
  double? carbsPer100,
  double? fatPer100,
}) {
  return Ingredient(
    name: name ?? 'Chicken Breast',
    amount: amount ?? '200',
    unit: unit ?? 'g',
    foodItemId: foodItemId,
    caloriesPer100: caloriesPer100 ?? 165.0,
    proteinPer100: proteinPer100 ?? 31.0,
    carbsPer100: carbsPer100 ?? 0.0,
    fatPer100: fatPer100 ?? 3.6,
  );
}

Map<String, dynamic> createTestIngredientMap({
  String? name,
  String? amount,
  String? unit,
  String? foodItemId,
  double? caloriesPer100,
  double? proteinPer100,
  double? carbsPer100,
  double? fatPer100,
}) {
  return {
    'name': name ?? 'Chicken Breast',
    'amount': amount ?? '200',
    'unit': unit ?? 'g',
    'foodItemId': foodItemId,
    'caloriesPer100': caloriesPer100 ?? 165.0,
    'proteinPer100': proteinPer100 ?? 31.0,
    'carbsPer100': carbsPer100 ?? 0.0,
    'fatPer100': fatPer100 ?? 3.6,
  };
}

// ---------------------------------------------------------------------------
// RecipeStep
// ---------------------------------------------------------------------------

RecipeStep createTestRecipeStep({
  int? order,
  String? instruction,
  String? imageUrl,
  int? timerSeconds,
}) {
  return RecipeStep(
    order: order ?? 1,
    instruction: instruction ?? 'Preheat oven to 180 degrees Celsius.',
    imageUrl: imageUrl,
    timerSeconds: timerSeconds,
  );
}

Map<String, dynamic> createTestRecipeStepMap({
  int? order,
  String? instruction,
  String? imageUrl,
  int? timerSeconds,
}) {
  return {
    'order': order ?? 1,
    'instruction': instruction ?? 'Preheat oven to 180 degrees Celsius.',
    'imageUrl': imageUrl,
    'timerSeconds': timerSeconds,
  };
}

// ---------------------------------------------------------------------------
// Recipe
// ---------------------------------------------------------------------------

Recipe createTestRecipe({
  String? id,
  String? title,
  String? description,
  String? authorId,
  String? authorName,
  String? category,
  int? servings,
  int? prepTimeMinutes,
  int? cookTimeMinutes,
  String? imageUrl,
  List<Ingredient>? ingredients,
  List<RecipeStep>? steps,
  int? caloriesPerServing,
  double? proteinGrams,
  double? carbsGrams,
  double? fatGrams,
  DateTime? createdAt,
  double? averageRating,
  int? ratingCount,
  int? commentCount,
  bool? isPrivate,
  List<String>? dietaryTags,
}) {
  return Recipe(
    id: id ?? 'recipe_001',
    title: title ?? 'Test Recipe',
    description: description ?? 'A delicious test recipe for unit testing.',
    authorId: authorId ?? 'user_001',
    authorName: authorName ?? 'Test Chef',
    category: category ?? 'Main Course',
    servings: servings ?? 4,
    prepTimeMinutes: prepTimeMinutes ?? 15,
    cookTimeMinutes: cookTimeMinutes ?? 30,
    imageUrl: imageUrl,
    ingredients: ingredients ?? [createTestIngredient()],
    steps: steps ?? [createTestRecipeStep()],
    caloriesPerServing: caloriesPerServing ?? 350,
    proteinGrams: proteinGrams ?? 28.0,
    carbsGrams: carbsGrams ?? 35.0,
    fatGrams: fatGrams ?? 12.0,
    createdAt: createdAt ?? DateTime(2025, 1, 15, 12, 0, 0),
    averageRating: averageRating ?? 4.5,
    ratingCount: ratingCount ?? 10,
    commentCount: commentCount ?? 3,
    isPrivate: isPrivate ?? false,
    dietaryTags: dietaryTags ?? const [],
  );
}

Map<String, dynamic> createTestRecipeMap({
  String? title,
  String? description,
  String? authorId,
  String? authorName,
  String? category,
  int? servings,
  int? prepTimeMinutes,
  int? cookTimeMinutes,
  String? imageUrl,
  List<Map<String, dynamic>>? ingredients,
  List<Map<String, dynamic>>? steps,
  int? caloriesPerServing,
  double? proteinGrams,
  double? carbsGrams,
  double? fatGrams,
  String? createdAt,
  double? averageRating,
  int? ratingCount,
  int? commentCount,
  bool? isPrivate,
  List<String>? dietaryTags,
}) {
  return {
    'title': title ?? 'Test Recipe',
    'description': description ?? 'A delicious test recipe for unit testing.',
    'authorId': authorId ?? 'user_001',
    'authorName': authorName ?? 'Test Chef',
    'category': category ?? 'Main Course',
    'servings': servings ?? 4,
    'prepTimeMinutes': prepTimeMinutes ?? 15,
    'cookTimeMinutes': cookTimeMinutes ?? 30,
    'imageUrl': imageUrl,
    'ingredients': ingredients ?? [createTestIngredientMap()],
    'steps': steps ?? [createTestRecipeStepMap()],
    'caloriesPerServing': caloriesPerServing ?? 350,
    'proteinGrams': proteinGrams ?? 28.0,
    'carbsGrams': carbsGrams ?? 35.0,
    'fatGrams': fatGrams ?? 12.0,
    'createdAt': createdAt ?? '2025-01-15T12:00:00.000',
    'averageRating': averageRating ?? 4.5,
    'ratingCount': ratingCount ?? 10,
    'commentCount': commentCount ?? 3,
    'isPrivate': isPrivate ?? false,
    'dietaryTags': dietaryTags ?? const [],
  };
}

// ---------------------------------------------------------------------------
// UserModel
// ---------------------------------------------------------------------------

UserModel createTestUser({
  String? uid,
  String? email,
  String? firstName,
  String? lastName,
  String? phoneNumber,
  String? photoUrl,
  String? bio,
  String? role,
  DateTime? createdAt,
  DateTime? birthDate,
  String? gender,
  double? heightCm,
  double? weightKg,
  String? activityLevel,
  String? cookingSkillLevel,
  int? followingCount,
  int? followersCount,
  String? username,
  bool? isBanned,
  String? banReason,
  DateTime? bannedAt,
  String? bannedBy,
}) {
  return UserModel(
    uid: uid ?? 'user_001',
    email: email ?? 'test@email.com',
    firstName: firstName ?? 'John',
    lastName: lastName ?? 'Doe',
    phoneNumber: phoneNumber,
    photoUrl: photoUrl,
    bio: bio,
    role: role ?? 'user',
    createdAt: createdAt ?? DateTime(2025, 1, 1, 10, 0, 0),
    birthDate: birthDate,
    gender: gender,
    heightCm: heightCm,
    weightKg: weightKg,
    activityLevel: activityLevel,
    cookingSkillLevel: cookingSkillLevel,
    followingCount: followingCount ?? 0,
    followersCount: followersCount ?? 0,
    username: username,
    isBanned: isBanned ?? false,
    banReason: banReason,
    bannedAt: bannedAt,
    bannedBy: bannedBy,
  );
}

Map<String, dynamic> createTestUserMap({
  String? uid,
  String? email,
  String? firstName,
  String? lastName,
  String? phoneNumber,
  String? photoUrl,
  String? bio,
  String? role,
  String? createdAt,
  String? birthDate,
  String? gender,
  double? heightCm,
  double? weightKg,
  String? activityLevel,
  String? cookingSkillLevel,
  int? followingCount,
  int? followersCount,
  String? username,
  bool? isBanned,
  String? banReason,
  String? bannedAt,
  String? bannedBy,
}) {
  return {
    'uid': uid ?? 'user_001',
    'email': email ?? 'test@email.com',
    'firstName': firstName ?? 'John',
    'lastName': lastName ?? 'Doe',
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'bio': bio,
    'role': role ?? 'user',
    'createdAt': createdAt ?? '2025-01-01T10:00:00.000',
    'birthDate': birthDate,
    'gender': gender,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'activityLevel': activityLevel,
    'cookingSkillLevel': cookingSkillLevel,
    'followingCount': followingCount ?? 0,
    'followersCount': followersCount ?? 0,
    'username': username,
    'isBanned': isBanned ?? false,
    'banReason': banReason,
    'bannedAt': bannedAt,
    'bannedBy': bannedBy,
  };
}

// ---------------------------------------------------------------------------
// FoodItem
// ---------------------------------------------------------------------------

FoodItem createTestFoodItem({
  String? id,
  String? name,
  String? brand,
  String? category,
  String? unit,
  double? packetSize,
  String? barcode,
  bool? isVegan,
  bool? isVegetarian,
  bool? isGlutenFree,
  double? calories,
  double? protein,
  double? carbs,
  double? fat,
  double? saturatedFat,
  double? transFat,
  double? cholesterol,
  double? fiber,
  double? sugar,
  double? sodium,
  double? salt,
  String? nutriScore,
  int? novaGroup,
  List<String>? allergens,
  String? ingredientsText,
  String? origin,
  double? servingSize,
  String? imageUrl,
  String? addedBy,
  DateTime? createdAt,
  bool? isVerified,
}) {
  return FoodItem(
    id: id ?? 'food_001',
    name: name ?? 'Whole Wheat Bread',
    brand: brand,
    category: category ?? 'Bakery',
    unit: unit ?? '100g',
    packetSize: packetSize ?? 400.0,
    barcode: barcode,
    isVegan: isVegan ?? false,
    isVegetarian: isVegetarian ?? true,
    isGlutenFree: isGlutenFree ?? false,
    calories: calories ?? 247.0,
    protein: protein ?? 13.0,
    carbs: carbs ?? 41.0,
    fat: fat ?? 3.4,
    saturatedFat: saturatedFat ?? 0.7,
    transFat: transFat ?? 0.0,
    cholesterol: cholesterol ?? 0.0,
    fiber: fiber ?? 7.0,
    sugar: sugar ?? 6.0,
    sodium: sodium ?? 400.0,
    salt: salt ?? 1.0,
    nutriScore: nutriScore,
    novaGroup: novaGroup,
    allergens: allergens ?? const [],
    ingredientsText: ingredientsText,
    origin: origin,
    servingSize: servingSize,
    imageUrl: imageUrl,
    addedBy: addedBy ?? 'user_001',
    createdAt: createdAt ?? DateTime(2025, 1, 10, 8, 0, 0),
    isVerified: isVerified ?? false,
  );
}

Map<String, dynamic> createTestFoodItemMap({
  String? name,
  String? brand,
  String? category,
  String? unit,
  double? packetSize,
  String? barcode,
  bool? isVegan,
  bool? isVegetarian,
  bool? isGlutenFree,
  double? calories,
  double? protein,
  double? carbs,
  double? fat,
  double? saturatedFat,
  double? transFat,
  double? cholesterol,
  double? fiber,
  double? sugar,
  double? sodium,
  double? salt,
  String? nutriScore,
  int? novaGroup,
  List<String>? allergens,
  String? ingredientsText,
  String? origin,
  double? servingSize,
  String? imageUrl,
  String? addedBy,
  String? createdAt,
  bool? isVerified,
}) {
  return {
    'name': name ?? 'Whole Wheat Bread',
    'brand': brand,
    'category': category ?? 'Bakery',
    'unit': unit ?? '100g',
    'packetSize': packetSize ?? 400.0,
    'barcode': barcode,
    'isVegan': isVegan ?? false,
    'isVegetarian': isVegetarian ?? true,
    'isGlutenFree': isGlutenFree ?? false,
    'calories': calories ?? 247.0,
    'protein': protein ?? 13.0,
    'carbs': carbs ?? 41.0,
    'fat': fat ?? 3.4,
    'saturatedFat': saturatedFat ?? 0.7,
    'transFat': transFat ?? 0.0,
    'cholesterol': cholesterol ?? 0.0,
    'fiber': fiber ?? 7.0,
    'sugar': sugar ?? 6.0,
    'sodium': sodium ?? 400.0,
    'salt': salt ?? 1.0,
    'nutriScore': nutriScore,
    'novaGroup': novaGroup,
    'allergens': allergens ?? const [],
    'ingredientsText': ingredientsText,
    'origin': origin,
    'servingSize': servingSize,
    'imageUrl': imageUrl,
    'addedBy': addedBy ?? 'user_001',
    'createdAt': createdAt ?? '2025-01-10T08:00:00.000',
    'isVerified': isVerified ?? false,
  };
}

// ---------------------------------------------------------------------------
// Favorite
// ---------------------------------------------------------------------------

Favorite createTestFavorite({
  String? id,
  String? userId,
  String? recipeId,
  DateTime? createdAt,
}) {
  return Favorite(
    id: id ?? 'fav_001',
    userId: userId ?? 'user_001',
    recipeId: recipeId ?? 'recipe_001',
    createdAt: createdAt ?? DateTime(2025, 2, 1, 14, 30, 0),
  );
}

Map<String, dynamic> createTestFavoriteMap({
  String? userId,
  String? recipeId,
  String? createdAt,
}) {
  return {
    'userId': userId ?? 'user_001',
    'recipeId': recipeId ?? 'recipe_001',
    'createdAt': createdAt ?? '2025-02-01T14:30:00.000',
  };
}

// ---------------------------------------------------------------------------
// Rating
// ---------------------------------------------------------------------------

Rating createTestRating({
  String? id,
  String? recipeId,
  String? userId,
  int? stars,
  DateTime? createdAt,
}) {
  return Rating(
    id: id ?? 'rating_001',
    recipeId: recipeId ?? 'recipe_001',
    userId: userId ?? 'user_001',
    stars: stars ?? 4,
    createdAt: createdAt ?? DateTime(2025, 2, 5, 16, 0, 0),
  );
}

Map<String, dynamic> createTestRatingMap({
  String? recipeId,
  String? userId,
  int? stars,
  String? createdAt,
}) {
  return {
    'recipeId': recipeId ?? 'recipe_001',
    'userId': userId ?? 'user_001',
    'stars': stars ?? 4,
    'createdAt': createdAt ?? '2025-02-05T16:00:00.000',
  };
}

// ---------------------------------------------------------------------------
// Comment
// ---------------------------------------------------------------------------

Comment createTestComment({
  String? id,
  String? recipeId,
  String? userId,
  String? authorName,
  String? text,
  int? stars,
  DateTime? createdAt,
}) {
  return Comment(
    id: id ?? 'comment_001',
    recipeId: recipeId ?? 'recipe_001',
    userId: userId ?? 'user_001',
    authorName: authorName ?? 'John Doe',
    text: text ?? 'Great recipe! Easy to follow and delicious.',
    stars: stars ?? 0,
    createdAt: createdAt ?? DateTime(2025, 2, 10, 9, 15, 0),
  );
}

Map<String, dynamic> createTestCommentMap({
  String? recipeId,
  String? userId,
  String? authorName,
  String? text,
  int? stars,
  String? createdAt,
}) {
  return {
    'recipeId': recipeId ?? 'recipe_001',
    'userId': userId ?? 'user_001',
    'authorName': authorName ?? 'John Doe',
    'text': text ?? 'Great recipe! Easy to follow and delicious.',
    'stars': stars ?? 0,
    'createdAt': createdAt ?? '2025-02-10T09:15:00.000',
  };
}

// ---------------------------------------------------------------------------
// MealEntry
// ---------------------------------------------------------------------------

MealEntry createTestMealEntry({
  String? name,
  MealType? mealType,
  String? foodItemId,
  String? recipeId,
  double? quantity,
  String? unit,
  double? calories,
  double? protein,
  double? carbs,
  double? fat,
}) {
  return MealEntry(
    name: name ?? 'Grilled Chicken',
    mealType: mealType ?? MealType.lunch,
    foodItemId: foodItemId,
    recipeId: recipeId,
    quantity: quantity ?? 150.0,
    unit: unit ?? 'g',
    calories: calories ?? 248.0,
    protein: protein ?? 46.5,
    carbs: carbs ?? 0.0,
    fat: fat ?? 5.4,
  );
}

Map<String, dynamic> createTestMealEntryMap({
  String? name,
  String? mealType,
  String? foodItemId,
  String? recipeId,
  double? quantity,
  String? unit,
  double? calories,
  double? protein,
  double? carbs,
  double? fat,
}) {
  return {
    'name': name ?? 'Grilled Chicken',
    'mealType': mealType ?? 'lunch',
    'foodItemId': foodItemId,
    'recipeId': recipeId,
    'quantity': quantity ?? 150.0,
    'unit': unit ?? 'g',
    'calories': calories ?? 248.0,
    'protein': protein ?? 46.5,
    'carbs': carbs ?? 0.0,
    'fat': fat ?? 5.4,
  };
}

// ---------------------------------------------------------------------------
// DailyLog
// ---------------------------------------------------------------------------

DailyLog createTestDailyLog({
  String? id,
  String? userId,
  String? date,
  List<MealEntry>? meals,
  int? waterMl,
}) {
  return DailyLog(
    id: id ?? 'log_001',
    userId: userId ?? 'user_001',
    date: date ?? '2025-02-15',
    meals: meals ?? [createTestMealEntry()],
    waterMl: waterMl ?? 1500,
  );
}

Map<String, dynamic> createTestDailyLogMap({
  String? userId,
  String? date,
  List<Map<String, dynamic>>? meals,
  int? waterMl,
}) {
  return {
    'userId': userId ?? 'user_001',
    'date': date ?? '2025-02-15',
    'meals': meals ?? [createTestMealEntryMap()],
    'waterMl': waterMl ?? 1500,
  };
}

// ---------------------------------------------------------------------------
// NutritionGoal
// ---------------------------------------------------------------------------

NutritionGoal createTestNutritionGoal({
  String? userId,
  double? calorieTarget,
  double? proteinTarget,
  double? carbsTarget,
  double? fatTarget,
  int? waterTargetMl,
}) {
  return NutritionGoal(
    userId: userId ?? 'user_001',
    calorieTarget: calorieTarget ?? 2000.0,
    proteinTarget: proteinTarget ?? 50.0,
    carbsTarget: carbsTarget ?? 250.0,
    fatTarget: fatTarget ?? 65.0,
    waterTargetMl: waterTargetMl ?? 2500,
  );
}

Map<String, dynamic> createTestNutritionGoalMap({
  double? calorieTarget,
  double? proteinTarget,
  double? carbsTarget,
  double? fatTarget,
  int? waterTargetMl,
}) {
  return {
    'calorieTarget': calorieTarget ?? 2000.0,
    'proteinTarget': proteinTarget ?? 50.0,
    'carbsTarget': carbsTarget ?? 250.0,
    'fatTarget': fatTarget ?? 65.0,
    'waterTargetMl': waterTargetMl ?? 2500,
  };
}

// ---------------------------------------------------------------------------
// ShoppingItem
// ---------------------------------------------------------------------------

ShoppingItem createTestShoppingItem({
  String? name,
  String? amount,
  String? unit,
  bool? isChecked,
}) {
  return ShoppingItem(
    name: name ?? 'Tomatoes',
    amount: amount ?? '500',
    unit: unit ?? 'g',
    isChecked: isChecked ?? false,
  );
}

Map<String, dynamic> createTestShoppingItemMap({
  String? name,
  String? amount,
  String? unit,
  bool? isChecked,
}) {
  return {
    'name': name ?? 'Tomatoes',
    'amount': amount ?? '500',
    'unit': unit ?? 'g',
    'isChecked': isChecked ?? false,
  };
}

// ---------------------------------------------------------------------------
// ShoppingList
// ---------------------------------------------------------------------------

ShoppingList createTestShoppingList({
  String? id,
  String? userId,
  String? name,
  List<ShoppingItem>? items,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return ShoppingList(
    id: id ?? 'list_001',
    userId: userId ?? 'user_001',
    name: name ?? 'Weekly Groceries',
    items: items ?? [createTestShoppingItem()],
    createdAt: createdAt ?? DateTime(2025, 3, 1, 10, 0, 0),
    updatedAt: updatedAt ?? DateTime(2025, 3, 1, 10, 0, 0),
  );
}

Map<String, dynamic> createTestShoppingListMap({
  String? userId,
  String? name,
  List<Map<String, dynamic>>? items,
  String? createdAt,
  String? updatedAt,
}) {
  return {
    'userId': userId ?? 'user_001',
    'name': name ?? 'Weekly Groceries',
    'items': items ?? [createTestShoppingItemMap()],
    'createdAt': createdAt ?? '2025-03-01T10:00:00.000',
    'updatedAt': updatedAt ?? '2025-03-01T10:00:00.000',
  };
}

// ---------------------------------------------------------------------------
// PlannedMeal
// ---------------------------------------------------------------------------

PlannedMeal createTestPlannedMeal({
  int? day,
  String? mealType,
  String? recipeId,
  String? recipeName,
  String? recipeImageUrl,
  int? servings,
}) {
  return PlannedMeal(
    day: day ?? 0,
    mealType: mealType ?? 'breakfast',
    recipeId: recipeId ?? 'recipe_001',
    recipeName: recipeName ?? 'Test Recipe',
    recipeImageUrl: recipeImageUrl,
    servings: servings ?? 1,
  );
}

Map<String, dynamic> createTestPlannedMealMap({
  int? day,
  String? mealType,
  String? recipeId,
  String? recipeName,
  String? recipeImageUrl,
  int? servings,
}) {
  return {
    'day': day ?? 0,
    'mealType': mealType ?? 'breakfast',
    'recipeId': recipeId ?? 'recipe_001',
    'recipeName': recipeName ?? 'Test Recipe',
    'recipeImageUrl': recipeImageUrl,
    'servings': servings ?? 1,
  };
}

// ---------------------------------------------------------------------------
// MealPlan
// ---------------------------------------------------------------------------

MealPlan createTestMealPlan({
  String? id,
  String? userId,
  DateTime? weekStartDate,
  List<PlannedMeal>? meals,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return MealPlan(
    id: id ?? 'plan_001',
    userId: userId ?? 'user_001',
    weekStartDate: weekStartDate ?? DateTime.utc(2025, 3, 17), // a Monday
    meals: meals ?? [createTestPlannedMeal()],
    createdAt: createdAt ?? DateTime(2025, 3, 17, 10, 0, 0),
    updatedAt: updatedAt ?? DateTime(2025, 3, 17, 10, 0, 0),
  );
}

// ---------------------------------------------------------------------------
// AdminLog
// ---------------------------------------------------------------------------

AdminLog createTestAdminLog({
  String? id,
  String? adminId,
  String? adminName,
  String? action,
  String? targetId,
  String? targetName,
  String? details,
  DateTime? createdAt,
}) {
  return AdminLog(
    id: id ?? 'log_001',
    adminId: adminId ?? 'admin_001',
    adminName: adminName ?? 'Admin User',
    action: action ?? 'ban_user',
    targetId: targetId ?? 'user_002',
    targetName: targetName ?? 'John Doe',
    details: details ?? 'Violated community guidelines',
    createdAt: createdAt ?? DateTime(2025, 3, 1, 10, 0, 0),
  );
}

Map<String, dynamic> createTestAdminLogMap({
  String? adminId,
  String? adminName,
  String? action,
  String? targetId,
  String? targetName,
  String? details,
  String? createdAt,
}) {
  return {
    'adminId': adminId ?? 'admin_001',
    'adminName': adminName ?? 'Admin User',
    'action': action ?? 'ban_user',
    'targetId': targetId ?? 'user_002',
    'targetName': targetName ?? 'John Doe',
    'details': details ?? 'Violated community guidelines',
    'createdAt': createdAt ?? '2025-03-01T10:00:00.000',
  };
}

// ---------------------------------------------------------------------------
// BanAppeal
// ---------------------------------------------------------------------------

BanAppeal createTestBanAppeal({
  String? id,
  String? userId,
  String? userName,
  String? userEmail,
  String? appealText,
  String? status,
  String? reviewedBy,
  String? reviewNote,
  DateTime? createdAt,
  DateTime? reviewedAt,
}) {
  return BanAppeal(
    id: id ?? 'appeal_001',
    userId: userId ?? 'user_002',
    userName: userName ?? 'John Doe',
    userEmail: userEmail ?? 'john@example.com',
    appealText: appealText ?? 'I believe my ban was a mistake.',
    status: status ?? 'pending',
    reviewedBy: reviewedBy,
    reviewNote: reviewNote,
    createdAt: createdAt ?? DateTime(2025, 3, 5, 14, 0, 0),
    reviewedAt: reviewedAt,
  );
}

Map<String, dynamic> createTestBanAppealMap({
  String? userId,
  String? userName,
  String? userEmail,
  String? appealText,
  String? status,
  String? reviewedBy,
  String? reviewNote,
  String? createdAt,
  String? reviewedAt,
}) {
  return {
    'userId': userId ?? 'user_002',
    'userName': userName ?? 'John Doe',
    'userEmail': userEmail ?? 'john@example.com',
    'appealText': appealText ?? 'I believe my ban was a mistake.',
    'status': status ?? 'pending',
    'reviewedBy': reviewedBy,
    'reviewNote': reviewNote,
    'createdAt': createdAt ?? '2025-03-05T14:00:00.000',
    'reviewedAt': reviewedAt,
  };
}

// ---------------------------------------------------------------------------
// Announcement
// ---------------------------------------------------------------------------

Announcement createTestAnnouncement({
  String? id,
  String? title,
  String? body,
  String? authorId,
  String? authorName,
  DateTime? createdAt,
}) {
  return Announcement(
    id: id ?? 'ann_001',
    title: title ?? 'Welcome to ChefSpecials!',
    body: body ?? 'We are excited to announce new features.',
    authorId: authorId ?? 'admin_001',
    authorName: authorName ?? 'Admin User',
    createdAt: createdAt ?? DateTime(2025, 3, 10, 9, 0, 0),
  );
}

Map<String, dynamic> createTestAnnouncementMap({
  String? title,
  String? body,
  String? authorId,
  String? authorName,
  String? createdAt,
}) {
  return {
    'title': title ?? 'Welcome to ChefSpecials!',
    'body': body ?? 'We are excited to announce new features.',
    'authorId': authorId ?? 'admin_001',
    'authorName': authorName ?? 'Admin User',
    'createdAt': createdAt ?? '2025-03-10T09:00:00.000',
  };
}
