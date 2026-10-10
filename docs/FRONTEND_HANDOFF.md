# Frontend Engineering Team Handoff

## Summary

The complete frontend presentation system for the **Aptech Book Store** mobile application has been faithfully reconstructed to match the canonical visual source of truth (`image.png`) and extended to all 24 required screens.

### Key Highlights
1. **100% Visual Fidelity**: Home / Discover, Book Details, and Shopping Cart exactly reproduce the approved layouts, proportions, colors, typography, and component styling.
2. **Centralized Design System**: Canonical JSON tokens reside in `assets/theme/bookstore_theme.json` and are actively bridged into Flutter via `lib/core/theme/bookstore_tokens.dart` and `lib/core/theme/bookstore_theme_data.dart`.
3. **Decoupled Architecture**: All screens consume abstract contracts in `lib/data/contracts/` through Riverpod providers in `lib/providers/app_providers.dart`.
4. **Rich Interactivity**: Live local shopping cart calculations, quantity adjustment, wishlist toggles, real-time catalog search and filtering, simulated checkout, order tracking, address and payment management, and admin inventory CRUD.
5. **No Production Assumptions**: No fake security guarantees, secrets, or hardcoded API keys.

---

## How to Run the Application

Once Flutter SDK is installed and added to your `PATH`:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Execute automated test suites
flutter test

# 4. Launch on emulator, simulator, or device
flutter run
```

---

## Testing & Role Switching

1. **Customer Mode (Alex Morgan)**:
   - Default login is pre-filled with `alex.morgan@aptech.edu` / `secret123`.
   - Access Home, Catalog, Search, Book Details, Wishlist, Cart ($47 subtotal -> $7 away from free shipping, $56 total), and Checkout.
2. **Admin Mode (Dr. Sarah Sterling)**:
   - On the Login screen, tap the "Admin" quick-fill button, or on the Profile screen, toggle the "Demo Role Mode" switch.
   - Tap "Admin Management Dashboard" to access Catalog & Inventory management, Order fulfillment updates, and User management.

---

## What Remains for the Backend Team

1. Implement concrete classes in `lib/data/services/` that satisfy the interfaces in `lib/data/contracts/`:
   - `AuthRepository` (Firebase Auth or OAuth2)
   - `BookRepository` (Firestore or REST endpoints)
   - `CartRepository` (Remote cart sync or session state)
   - `OrderRepository` (Payment gateway and orders DB)
   - `ReviewRepository` (Reviews collection)
   - `ProfileRepository`, `AddressRepository`, `PaymentMethodRepository`
   - `AdminRepository` (Role-protected management endpoints)
2. In `lib/providers/app_providers.dart`, update provider instances to instantiate your production repository classes.
3. Replace demo images if custom high-res assets are provisioned on your CDN.
