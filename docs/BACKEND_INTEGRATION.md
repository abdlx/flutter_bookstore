# Firebase backend integration

The bookstore uses Firebase Authentication and Cloud Firestore on the free Spark plan. The user selected project `flutter-project1-86917`. FlutterFire configuration is checked in for Android, iOS, macOS, web and Windows. There are no Cloud Functions, merchant credentials, runtime mock repositories, seeded customers or sample catalog fallback.

## Repository contracts

Interfaces remain in `lib/data/contracts/`. `lib/providers/app_providers.dart` binds them to the implementations in `lib/data/firestore/`:

| Contract | Implementation | Persistence |
| --- | --- | --- |
| AuthRepository | FirebaseAuthRepository | Firebase Auth and users/{uid} |
| BookRepository | FirestoreBookRepository | books |
| CartRepository | FirestoreCartRepository | users/{uid}/cart, current books and store settings |
| WishlistRepository | FirestoreWishlistRepository | users/{uid}/wishlist and current books |
| OrderRepository | FirestoreOrderRepository | orders and atomic stock/cart writes |
| ReviewRepository | FirestoreReviewRepository | books/{bookId}/reviews/{uid} and atomic book aggregates |
| ProfileRepository | FirestoreProfileRepository | users/{uid}; verified Firebase Auth email changes |
| AddressRepository | FirestoreAddressRepository | users/{uid}/addresses |
| PaymentMethodRepository | FirestorePaymentMethodRepository | users/{uid}/paymentMethods |
| AdminRepository | FirestoreAdminRepository | protected inventory, fulfillment, user roles and dashboard queries |

Customer repositories are scoped to the authenticated UID. Their subscriptions are disposed on account changes. Catalog, cart, wishlist, address, payment, order-list and individual-order screens use snapshots. Search and genre choices derive from the actual catalog. Empty collections stay empty.

## Firestore schema

| Path | Fields |
| --- | --- |
| books/{bookId} | title, author, genre, tags, description, coverUrl, price, optional originalPrice, format, pages, language, publisher, stockQuantity, publishedDate (Timestamp or ISO string), isBestseller, isRecommended |
| books/{bookId}/reviews/{uid} | userId, userName, userAvatar, rating (integer 1-5), content, createdAt, helpfulCount |
| users/{uid} | fullName, email, phone, avatarUrl, role (customer/admin), membershipTier, memberSince; optional addressesDefaultId/paymentMethodsDefaultId |
| users/{uid}/cart/{bookId} | bookId, quantity |
| users/{uid}/wishlist/{bookId} | bookId |
| users/{uid}/addresses/{addressId} | label, recipientName, phone, street, city, state, postalCode, country, isDefault |
| users/{uid}/paymentMethods/{methodId} | type (cod), title, subtitle, isDefault |
| settings/store | freeShippingThreshold, shippingFee, taxRate (decimal fraction); optional storefrontUrl for copied book links |
| promotions/{UPPERCASE_CODE} | active, type (fixed/percent), amount, optional minimumSubtotal, optional expiresAt (Timestamp) |
| orders/{orderId} | userId, orderNumber, items (bookId/quantity/immutable book snapshot), itemIndex, addressId/shippingAddress, paymentMethodId/paymentMethod, subtotal/shipping/tax/discount/total, promoCode, createdAt, status, paymentStatus, statusHistory |

Document IDs are authoritative. Cart and wishlist records hold book references, not trusted prices. Reviews maintain rating, reviewCount, ratingCounts and ratingBreakdown on books. These aggregates can change only with a valid matching review transaction. lastOrderId is an internal stock-write linkage; administrator forms preserve it.

## Free-plan checkout

Firestore transactions perform the writes and the deployed `firestore.rules` validate them on the server. Client-side validation is for feedback; it is not the authorization boundary.

A checkout re-reads its cart lines, current book data, selected saved address/payment, store settings and promotion before writing. It computes money in integer cents and commits the immutable receipt, stock decrements and purchased-cart deletions atomically. A stable random checkout ID makes retries idempotent. A concurrent stock change causes the transaction to retry and revalidate availability.

An order supports **one to five distinct titles**, with quantities limited by current stock. This bounded size allows the rules to validate each line and stay within Firestore document-access and expression limits. The emulator suite includes the maximum-size order with a promotion. The UI reports the limit when a larger cart reaches checkout. A larger-order design would require a different server-validation architecture.

The rules require every order line to reference a stock update whose lastOrderId matches the new receipt. That book update must use its actual pre-write snapshot, positive quantity, exact stock decrement and the same newly created customer-owned order. itemIndex links each distinct title to one line. Rules recompute subtotal, discount, shipping, tax and total from the validated line data and stored policies; altered prices, duplicate lines and missing stock writes are rejected.

Fulfillment allows placed -> confirmed -> processing -> shipped -> delivered, with cancellation before shipment. Administrator cancellation restores stock in the same transaction; repeating a terminal status is a no-op. statusHistory uses server timestamps. Cash-on-delivery payment is unpaid until delivery, then paid. Customers cannot change order status, payment state, prices or receipts.

**Cash on delivery is the supported payment method.** No card number/CVV is collected, stored or treated as a successful charge. Card payments need a real merchant processor and were not enabled for the free-plan setup.

## Authentication and authorization

Email/password registration, login, password reset, persisted sessions and verified email changes use Firebase Auth. New profiles are customers. The application has no demo role switch, default login, self-promotion or fake membership/revenue data. Administrators may change another user's role; the rules prevent changing their own role.

`firestore.rules` permits public book/review/store-settings reads, owner-only private customer data, and administrator inventory/user/fulfillment management. Unspecified paths are denied. Current queries require no composite indexes: customer orders filter by userId and sort locally.

## Project setup

The project's original expired test rules were replaced with this application's rules. The database was empty when inspected; no books, users, orders, addresses or reviews were imported or fabricated.

1. Basic Firebase Authentication is initialized and Email/Password is enabled in the selected project. Basic authentication and the bookstore do not require upgrading to Blaze. The public Identity Platform initialization API is a different, billing-gated setup path.
2. The owner's registered account has been assigned its first administrator role through the authenticated project-owner API. For a new project, register the intended administrator and set only that real user's users/{uid}.role to admin through a trusted owner environment. Additional roles can then be managed in the app.
3. Use Admin -> Store Settings to create settings/store using the store's real shipping/tax policies (or write the document through a trusted owner environment). Checkout stays disabled while settings are absent.
4. Add actual inventory in the administrator book form, including stock and recommendation flags. Add actual promotion documents if required.

The app never seeds commercial records or silently falls back to an emulator. Source-controlled platform configurations do not contain service-account private keys. Do not commit CLI credentials, access tokens or service-account files.

## Deploy and verify

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web
flutter build apk --debug --target-platform android-arm64
npm --prefix firebase_tests ci
npx firebase-tools emulators:exec --project demo-bookstore --only firestore "node --test firebase_tests/test/emulator.test.js"
npx firebase-tools deploy --only firestore:rules,firestore:indexes --project flutter-project1-86917
```

Emulator tests create isolated fixtures only in demo-bookstore memory and never seed production. Java 21+ is required. iOS/macOS builds require their native Apple toolchains; Windows desktop plugin generation requires symlink support.

To run against local emulators:

```powershell
npx firebase-tools emulators:start --project flutter-project1-86917 --only auth,firestore
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=localhost
```

Use FIREBASE_EMULATOR_HOST=10.0.2.2 for an Android emulator. Production uses Firebase directly and reports initialization failures instead of bypassing them.

Reference: [Firestore transactions and getAfter validation](https://firebase.google.com/docs/firestore/manage-data/transactions), [security-rule limits](https://firebase.google.com/docs/firestore/quotas).
