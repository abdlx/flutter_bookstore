# BookStore — Frontend/Backend Merge Notes

Merged 2026-10-22. Target repo: `bookstore-app` (backend). Source of UI: `flutter_bookstore` (frontend).
Both apps share package `bookstore_app`, Firebase project `bookstore-app-4dca8` — `firebase_options.dart`,
`google-services.json` and `docs/firestore.rules` are the backend repo's originals, untouched.

## What changed

- **Presentation layer replaced** with the frontend's: `lib/features/` (24 screens), `lib/shared/`
  (premium design system), `lib/app/` (go_router), theme tokens (`lib/core/theme/` +
  `assets/theme/bookstore_theme.json`), `assets/images/`. Entry point is the frontend shell:
  `lib/main.dart` → `lib/app.dart` (`MaterialApp.router`).
- **Backend's old UI deleted**: `lib/screens/`, `lib/widgets/`, old `lib/providers/*`, `lib/services/`,
  `lib/models/` (kept in git history).
- **Data layer**: UI talks to the 10 contracts in `lib/data/contracts/`. Production implementations
  live in `lib/data/services/`, backed by FirebaseAuth + CloudFirestore (+ Storage), wired in
  `lib/providers/app_providers.dart` (mock imports removed; provider names/types unchanged).
  The mocks in `lib/data/mock/` are kept for reference/tests but are no longer wired.

## Firestore mapping used by the production repositories

| Repository | Location |
|---|---|
| Auth / Profile | `users/{uid}` (role override for the demo-role switch is local) |
| Books | `books` collection |
| Cart | `users/{uid}/cart` — totals mirror the mock's rules (free shipping ≥ $50, 8.5% tax, promo codes BOOKWORM / APTECH10 / WELCOME) |
| Wishlist | `wishlists/{uid}/books` |
| Orders | `orders` + mirror in `users/{uid}/orders` |
| Reviews | `books/{bookId}/reviews` (also updates the book's rating) |
| Addresses | `users/{uid}/addresses` |
| Payment methods | `users/{uid}/paymentMethods` |
| Admin | Aggregates across `books`, `orders`, `users` |

## Verify / run

```
flutter pub get
flutter analyze   # verified clean: "No issues found!" (Flutter 3.47.7, 2026-10-22)
flutter run
```

Release signing is the stock template (debug key) — add your own signing config before any store release.
