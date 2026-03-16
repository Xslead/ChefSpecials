# ChefSpecials

A Flutter-based food tracker and recipe sharing app with step-by-step cooking guidance and nutrition tracking.

## Features

- **Recipe Creation** — Add recipes with ingredients, steps, photos, nutrition info, and dietary tags (vegan, keto, halal, etc.)
- **Step-by-Step Cooking Mode** — PageView-based guided cooking with countdown timers
- **Daily Nutrition Tracker** — Log meals (breakfast, lunch, dinner, snack) with calorie, protein, carbs, and fat tracking against daily goals
- **Water Tracking** — Monitor daily water intake
- **Social Feed** — Follow other users, view their latest recipes, search by recipe or @username
- **Ratings & Comments** — Rate recipes (1–5 stars) and leave comments
- **Recipe Collections** — Organize saved recipes into custom folders
- **Shopping Lists** — Generate shopping lists from recipe ingredients, check off items
- **Search & Favorites** — Find recipes by name, ingredient, or category with advanced filters
- **Public/Private Recipes** — Control recipe visibility
- **Multilingual** — English and Turkish with full localization
- **User Profiles** — Bio, photo, follower/following counts, recipe portfolio
- **Dark Mode** — Full dark theme support with adaptive colors
- **Unified Design System** — Consistent spacing, border-radius, typography, and color tokens across all screens

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Language | Dart |
| Backend | Firebase (Firestore, Auth, Storage) |
| State Management | Provider |
| Routing | GoRouter |
| i18n | Flutter intl (ARB) |
| Charts | fl_chart |
| Sharing | share_plus |

## Project Structure

```
lib/
├── config/       # Theme, constants, routes
├── l10n/         # Localization (en, tr)
├── models/       # Data models with Firestore serialization
├── services/     # Firebase interaction layer (no UI logic)
├── providers/    # ChangeNotifier state management
├── screens/      # Feature-grouped screens
│   ├── auth/            # Login, register
│   ├── home/            # Recipe feed with filters
│   ├── feed/            # Social feed (followed users)
│   ├── daily_tracker/   # Nutrition & water tracking
│   ├── profile/         # User profile, edit, public view
│   ├── add_recipe/      # Recipe creation form
│   ├── edit_recipe/     # Recipe editing
│   ├── recipe_detail/   # Full recipe view with ratings
│   ├── cooking_mode/    # Step-by-step cooking
│   ├── search/          # Recipe & ingredient search
│   ├── favorites/       # Saved recipes
│   ├── collections/     # Recipe collections/folders
│   ├── shopping_list/   # Shopping lists
│   ├── food_items/      # Ingredient database
│   ├── my_recipes/      # User's own recipes
│   └── admin/           # Admin panel
├── widgets/      # Shared reusable widgets
└── utils/        # Helpers & validators

test/             # 861+ tests (models, services, providers, widgets)
```

## Setup

### Prerequisites
- Flutter SDK (stable channel)
- Xcode (for iOS builds)
- Android Studio (for Android builds)
- Firebase CLI + FlutterFire CLI

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

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Enable Firebase Storage
5. Run `flutterfire configure` to link the project

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
