# ChefSpecials

A Flutter-based food tracker and recipe sharing app with step-by-step cooking guidance and nutrition tracking.

## Features

- **Recipe Creation** — Add recipes with ingredients, steps, photos, and nutrition info
- **Step-by-Step Cooking Mode** — PageView-based guided cooking with optional timers
- **Nutrition Tracking** — Calories, protein, carbs, and fat per serving
- **Search & Favorites** — Find recipes by name/category, save favorites
- **Multilingual** — English and Turkish support
- **User Profiles** — View published recipes, edit bio and photo
- **Admin Panel** — In-app content management for admin users

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Language | Dart |
| Backend | Firebase (Firestore, Auth, Storage) |
| State Management | Provider |
| Routing | GoRouter |
| i18n | Flutter intl (ARB) |

## Project Structure

```
lib/
├── config/       # Theme, constants, routes
├── l10n/         # Localization (en, tr)
├── models/       # Data models
├── services/     # Firebase services
├── providers/    # State management
├── screens/      # Feature screens
├── widgets/      # Shared widgets
└── utils/        # Helpers & validators
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

## Screenshots

_Coming soon_

## License

MIT
