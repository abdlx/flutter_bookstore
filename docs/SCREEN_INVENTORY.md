# Screen Inventory & Navigation Directory

This inventory documents all 24 primary screens, auxiliary sheets, and their supported interactions.

## 1. Authentication & Onboarding
| # | Screen Name | Route Path | Implementation Status | Supported User Interactions |
|---|---|---|---|---|
| 1 | Splash Screen | `/` | Complete | Auto-branding animation, timer route transition |
| 2 | Onboarding / Welcome | `/onboarding` | Complete | Multi-slide carousel, indicators, Skip, Continue, Get Started |
| 3 | Login | `/login` | Complete | Form validation, password visibility toggle, quick-fill demo roles (Customer/Admin), auth submission |
| 4 | Registration | `/register` | Complete | Full name, email, password validation, terms checkbox, registration submission |
| 5 | Forgot Password | `/forgot-password` | Complete | Email input, reset link dispatch simulation, confirmation card |

## 2. Shopping & Discovery
| # | Screen Name | Route Path | Implementation Status | Supported User Interactions |
|---|---|---|---|---|
| 6 | Home / Discover (**Reference Screen 1**) | `/home` | Complete | Greeting, notifications, user avatar, search trigger, horizontal genre filters, photographic hero banner, recommended carousel, best sellers, add to cart, bottom navigation |
| 7 | Book Catalog / Explore | `/explore` | Complete | Grid / List view switcher, category chips filter, dynamic counts, direct cart addition, navigation to book details |
| 8 | Search Results & Filtering | `/search` | Complete | Real-time text search across title & author, filter bottom sheet (genre, price slider, sort order), empty search fallback |
| 9 | Book Details (**Reference Screen 2**) | `/book/:id` | Complete | Warm beige canvas, floating shadow cover, cover pagination, wishlist toggle, share, bestseller badge, category tags, 3-column metadata panel, expandable description, customer reviews breakdown, persistent quantity stepper, gold Add to Cart |
| 10 | Ratings & Reviews | `/book/:id/reviews` | Complete | Overall score, star distribution breakdown, review cards with helpful counts, Write Review modal sheet with interactive star rating & submission |
| 11 | Saved Wishlist | `/wishlist` | Complete | Saved book items, remove from wishlist, instant move-to-cart, empty state |
| 12 | Shopping Cart (**Reference Screen 3**) | `/cart` | Complete | Free shipping progress bar calculation ($7 away), rounded item cards, quantity steppers, item deletion, promo code modal sheet ($5 off with BOOKWORM), cost breakdown ($47+$5+$4=$56), Proceed to Checkout CTA |
| 13 | Checkout | `/checkout` | Complete | Delivery address selection, payment method selection, order items summary, order summary calculations, place order processing |
| 14 | Order Confirmation | `/order-confirmation/:orderId` | Complete | Order number display, purchase receipt summary, Track Order CTA, Continue Shopping |

## 3. Orders & Account
| # | Screen Name | Route Path | Implementation Status | Supported User Interactions |
|---|---|---|---|---|
| 15 | My Orders | `/orders` | Complete | Orders list with status badges (Shipped, Delivered), date placed, items count, total, tap to track |
| 16 | Order Details & Delivery Tracking | `/orders/:id` | Complete | Multi-stage vertical tracking timeline, delivery address details, order items breakdown, payment summary |
| 17 | My Profile | `/profile` | Complete | Profile card with tier badge, demo role switch (Customer <-> Admin), navigation to sub-settings, logout confirmation dialog |
| 18 | Edit Profile | `/profile/edit` | Complete | Name, email, phone editing, avatar display, validation, save |
| 19 | Address Management | `/profile/addresses` | Complete | Address cards, set as default toggle, delete address, add address CTA |
| — | Add / Edit Address | `/profile/addresses/edit` | Complete | Form with label, recipient, street, city, state, postal code, default switch |
| 20 | Payment Methods | `/profile/payments` | Complete | Stored cards, Apple Pay, set default, delete, add payment CTA |
| — | Add / Edit Payment | `/profile/payments/edit` | Complete | Cardholder name, card number, expiry, CVV, default switch |

## 4. Administration
| # | Screen Name | Route Path | Implementation Status | Supported User Interactions |
|---|---|---|---|---|
| 21 | Admin Dashboard | `/admin` | Complete | Revenue, orders, catalog and user stats cards, module navigation, demo banner |
| 22 | Book Management | `/admin/books` | Complete | Inventory search, stock counts, bestseller badges, edit book, delete with dialog, add book CTA |
| — | Add / Edit Book Form | `/admin/books/edit` | Complete | Form with title, author, genre, price, orig price, cover URL, stock count, publisher, pages, bestseller switch |
| 23 | Order Fulfillment Management | `/admin/orders` | Complete | Orders list, status change dialog (Placed, Processing, Shipped, Delivered, Cancelled) |
| 24 | User Management | `/admin/users` | Complete | User directory, roles display, interactive admin switch per user |
