# School-project implementation status

The implemented scope is the Firebase-backed bookstore described in the project docs, with the user-approved Spark plan, cash on delivery and administrator-managed delivery stages. Commercial payment processing and courier/GPS services are outside this school-project setup.

| Previously partial area | Implemented behavior | Evidence |
| --- | --- | --- |
| Promotions | Administrator create/edit/delete, fixed or percentage offers, minimum subtotal, expiry, active state | promotion_management_screen.dart, firestore_promotion_repository.dart, promotion emulator tests |
| Helpful votes | One toggle per authenticated reader, self-votes rejected, protected counts, concurrent voters preserved, review edits preserve votes | FirestoreReviewRepository, helpful-vote emulator test |
| Live data | Reviews, voter selections, dashboard statistics, user directory and orders subscribe to Firestore | app_providers.dart, repository streams |
| Photos | Gallery selection, bounded PNG resizing, Firestore persistence, covers/profile/review rendering | ImageUploadButton, StoreImage, image preparation Flutter test and media-rule emulator test |
| Catalog/search | Indexed word-prefix queries, genre/sort queries, 24-document cursor pages, bounded home feeds, individual document details | catalog_queries.dart, PagedCatalogView, paging emulator test and keyword Flutter test |
| Terms/privacy | Public versioned pages, administrator editor, explicit registration checkbox and persisted acceptance versions | PolicyScreen, PolicyEditorScreen, auth repository, policy-rule tests |
| Store configuration | Persisted USD 5 shipping, USD 50 free-shipping subtotal, zero tax; editable through administrator settings | settings/store in the selected Firebase project |
| Checkout verification | Actual emulator email/password accounts, private profile creation, catalog/cart/wishlist/address/payment persistence, checkout, delivery and isolation | Auth/Firestore end-to-end emulator test |

No live book catalog, review, promotion or order fixtures were generated. Test fixtures exist only in isolated emulators and Flutter tests. User-entered catalog and profile data comes from Firestore/Firebase Auth; missing records do not turn into sample content.

## Validation

- Flutter analysis: no issues.
- Flutter tests: 20 passing tests, including keyword/index normalization, image resize/encoding, promotions, live policy/dashboard UI updates, promotion form validation and the zero-count helpful action.
- Auth/Firestore emulator tests: 17 passing tests, including pricing tampering, stock races, maximum order size, review aggregates, vote races, media/policy/promotion permissions and authenticated checkout-to-delivery.
- Web release and Android ARM64 debug builds succeeded.
- All 15 deployed catalog index combinations were READY and their public live queries returned success.
- iOS/macOS/Windows native builds require their respective toolchains and have not been verified here.

## Defined limits

Checkout accepts one to five distinct titles per order. Helpful voting is limited to 10,000 voters per review. Images are public, immutable PNG media records capped at 450,000 bytes after resizing. Search is indexed keyword-prefix search; it does not claim typo correction or relevance ranking from an external search engine. Secondary terms and price caps filter the candidate pages, so additional pages may need to be loaded. These constraints are surfaced or documented and do not use fake successful payments, shipping events or business records.
