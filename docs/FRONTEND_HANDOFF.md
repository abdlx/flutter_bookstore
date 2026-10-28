# Application handoff

The feature-based Flutter application now binds every repository to Firebase Auth/Firestore. Runtime mock implementations and the obsolete duplicate app have been removed. See [backend integration](BACKEND_INTEGRATION.md) for collection fields, server behavior, deployment, first-admin setup and local emulator commands.

The original warm ivory/gold palette, Cormorant Garamond headings, Inter body text, shared widgets and tab navigation remain. Fonts are bundled for offline consistency. Covers use the persisted cover URL with a neutral title placeholder if the image is missing.

Implemented flows include authentication and password reset, live catalog and search filters, book details and reviews, customer wishlist/cart persistence, address create/edit/default/delete, cash-on-delivery methods, checkout validated by Firestore rules, live order receipts/tracking, profile editing, administrator inventory/recommendations, all-customer fulfillment, and protected role management.

All operational data must be supplied in Firestore. The app never fills empty collections with sample content or turns failed reads into fake success. The owner selected flutter-project1-86917; the free-plan Firestore rules are deployed, Email/Password authentication is enabled, and the owner's registered account has administrator access. Configure real shipping/tax settings and actual inventory through Admin Management before accepting orders.

Card charging is not implemented because no merchant provider is configured. The UI only offers cash on delivery and never stores card numbers or CVV.

Checkout supports up to five distinct titles per order on the Spark plan. The application no longer depends on Cloud Functions.

Validation on 2026-10-28: Flutter analysis passed with no issues, all 13 Flutter tests passed, and all 10 Firestore emulator tests passed. Web release and Android ARM64 debug builds succeeded. Live read checks confirmed public catalog access and denied unauthenticated customer-directory access. The owner registered through the live app; no production orders or catalog records were fabricated for testing. iOS, macOS and Windows native builds were not verified on this machine.
