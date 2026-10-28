# Aptech Book Store

Flutter bookstore following [the premium design system](docs/DESIGN_SYSTEM.md), with Firebase Auth, Firestore-backed customer and administrator flows, and transactional checkout validated by Firestore rules. No runtime sample catalog or mock repositories.

## Run

```powershell
flutter pub get
flutter run
```

Firebase options currently target `flutter-project1-86917` for Android, iOS, macOS, web and Windows. Follow [backend setup and deployment](docs/BACKEND_INTEGRATION.md) to enable authentication, deploy rules, configure real shipping/tax settings and assign the first administrator. Inventory is entered through the administrator app; an empty Firestore catalog remains empty.

The app runs on Firebase's free Spark plan. Checkout supports cash on delivery and up to five distinct titles per order. Card payments require a separately configured merchant processor.

## Check

```powershell
flutter analyze
flutter test
flutter build web
npm --prefix firebase_tests ci
npx firebase-tools emulators:exec --project demo-bookstore --only auth,firestore "node --test firebase_tests/test/emulator.test.js"
```

Firestore emulator tests require Java 21+. Test fixture data is isolated from the configured Firebase project.

Cormorant Garamond and Inter fonts are bundled with their OFL licenses in `assets/fonts/`.

Administrator features include inventory, fulfillment, user roles, shipping/tax configuration, promotions and published policy pages. Customers can upload profile photos and book reviewers can cast secure helpful votes. Catalog and keyword search use Firestore indexes and 24-document cursor pages. See [implementation status](docs/IMPLEMENTATION_STATUS.md) for scope and verification.
