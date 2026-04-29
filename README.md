# ChefSpecials

A Flutter-based food tracker and recipe sharing app with step-by-step cooking guidance, nutrition tracking, and social features.

## Features

- **Recipe Creation** — Add recipes with ingredients, steps, photos, nutrition info, and dietary tags (vegan, keto, halal, etc.)
- **Step-by-Step Cooking Mode** — PageView-based guided cooking with countdown timers
- **Cooking History** — Log every time you cook a recipe with personal rating, notes, and photos
- **Daily Nutrition Tracker** — Log meals (breakfast, lunch, dinner, snack) with calorie, protein, carbs, and fat tracking against daily goals
- **Water Tracking** — Monitor daily water intake
- **Nutrition Analytics & Reports** — Weekly/monthly macro charts, streak tracking, and shareable reports
- **Meal Planner** — Week-based meal planning with shopping list auto-sync and servings adjustment
- **Trending Recipes** — Popular This Week ranking with configurable time windows (7d / 30d / all time) and a scoring algorithm
- **Ingredient Substitution Suggestions** — Look up substitutes with ratios, dietary tags, and verification status
- **Achievement Badges** — 12 unlockable achievements across cooking, social, health, and exploration categories with progress tracking and celebration overlays
- **Social Feed** — Follow other users, view their latest recipes, search by recipe or @username
- **Activity Feed** — Consolidated notifications for follows, comments, ratings, new recipes, and announcements
- **Ratings & Comments** — Rate recipes (1–5 stars) and leave comments
- **Recipe Collections** — Organize saved recipes into custom folders
- **Shopping Lists** — Generate shopping lists from recipe ingredients, check off items
- **Search & Favorites** — Find recipes by name, ingredient, or category with advanced filters
- **Recipe Import** — Import recipes from external URLs into the recipe form
- **Public/Private Recipes** — Control recipe visibility
- **Push Notifications** — Firebase Messaging with per-category notification settings
- **Multilingual** — English and Turkish with full localization
- **Onboarding** — 4-page animated introduction for new users
- **User Profiles** — Bio, photo, follower/following counts, recipe portfolio, achievement display
- **Dark Mode** — Full dark theme support with adaptive colors
- **Admin Panel** — User/recipe/category management, ban appeals, announcement broadcasting, and audit logs

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Language | Dart |
| Backend | Firebase (Firestore, Auth, Storage, Messaging) |
| State Management | Provider |
| Routing | GoRouter |
| i18n | Flutter intl (ARB) |
| Charts | fl_chart |
| Animations | Lottie |
| Sharing | share_plus |

## Project Structure

```
lib/
├── config/           # Theme, constants, routes
├── l10n/             # Localization (en, tr)
├── models/           # Data models with Firestore serialization
├── services/         # Firebase interaction layer (no UI logic)
├── providers/        # ChangeNotifier state management
├── screens/          # Feature-grouped screens
│   ├── auth/                # Login, register, banned
│   ├── onboarding/          # Initial app walkthrough
│   ├── home/                # Recipe feed with filters
│   ├── feed/                # Social feed (followed users)
│   ├── trending/            # Popular recipes by time window
│   ├── daily_tracker/       # Nutrition & water tracking
│   ├── reports/             # Nutrition analytics and charts
│   ├── meal_planner/        # Weekly meal planning
│   ├── cooking_history/     # User's cooking log
│   ├── achievements/        # Achievement showcase and progress
│   ├── activity/            # Notification center and activity feed
│   ├── profile/             # User profile, edit, public view
│   ├── add_recipe/          # Recipe creation form
│   ├── edit_recipe/         # Recipe editing
│   ├── import_recipe/       # URL recipe importer
│   ├── recipe_detail/       # Full recipe view with ratings
│   ├── cooking_mode/        # Step-by-step cooking
│   ├── search/              # Recipe & ingredient search
│   ├── favorites/           # Saved recipes
│   ├── collections/         # Recipe collections/folders
│   ├── shopping_list/       # Shopping lists
│   ├── food_items/          # Ingredient database
│   ├── my_recipes/          # User's own recipes
│   └── admin/               # Admin panel
├── widgets/          # Shared reusable widgets
└── utils/            # Helpers & validators

test/             # 861+ tests (models, services, providers, widgets)
```

## Setup

### Prerequisites
- Flutter SDK (stable channel)
- Xcode (for iOS builds)
- Android Studio (for Android builds)
- Firebase CLI + FlutterFire CLI
- Docker (for web deployment)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd ChefSpecials

# Install dependencies
flutter pub get

# Configure Firebase (if not already configured)
flutterfire configure

# Run the app
flutter run
```

## Docker Deployment

```bash
# Build the web release
flutter build web

# Build the Docker image
docker build -t chef-specials .

# Run the container
docker run -p 8080:80 chef-specials
```

Open `http://localhost:8080` in your browser.

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Enable Firebase Storage
5. Enable Firebase Messaging
6. Run `flutterfire configure` to link the project

### Firebase Storage CORS (required for web)

Create a `cors.json` file and apply it to your Storage bucket so the browser can load images:

```bash
gsutil cors set cors.json gs://<your-storage-bucket>
```

## Firebase Collections

| Collection | Description |
|------------|-------------|
| `users` | User profiles with username, bio, photo |
| `recipes` | Published recipes with ingredients, steps, nutrition |
| `favorites` | User-recipe favorite links |
| `ratings` | Recipe ratings (1–5 stars) |
| `comments` | Recipe comments/reviews |
| `daily_logs` | Daily nutrition tracking logs |
| `shopping_lists` | User shopping lists with checkable items |
| `collections` | User recipe collections/folders |
| `follows` | User follow relationships |
| `food_items` | Ingredient database (nutrition per 100g/mL) |
| `nutrition_goals` | User daily nutrition targets |
| `cooking_logs` | Per-recipe cooking history entries |
| `meal_plans` | Weekly meal plans with slot assignments |
| `user_achievements` | Achievement unlock records and progress |
| `substitutions` | Ingredient substitution database |
| `activities` | Activity feed (follows, comments, ratings, announcements) |
| `announcements` | Admin broadcast announcements |
| `appeals` | User ban appeal submissions |
| `admin_logs` | Admin action audit trail |

## Testing

```bash
# Run all tests (861+)
flutter test

# Run with coverage
flutter test --coverage

# Static analysis
flutter analyze --no-pub
```

## Screenshots

_Coming soon_

## License

MIT
