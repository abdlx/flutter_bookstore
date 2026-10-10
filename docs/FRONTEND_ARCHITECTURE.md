# Frontend Architecture Documentation

## Overview

The Aptech Book Store application frontend is architected as an enterprise-grade Flutter presentation system designed with strict separation of concerns, high visual fidelity, modular features, and a decoupled repository pattern.

## Directory Structure

```text
lib/
├── app/
│   ├── app.dart                    # Application root & theme binding
│   └── router/
│       ├── app_router.dart         # GoRouter configuration with StatefulShellRoute
│       └── route_paths.dart        # Type-safe route URI constants
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Backward-compatible color bridge
│   │   ├── app_dimensions.dart     # Sizing tokens
│   │   └── app_typography.dart     # Font scale definitions
│   ├── models/                     # Strongly-typed domain entity models
│   │   ├── address.dart
│   │   ├── book.dart
│   │   ├── cart_item.dart
│   │   ├── category.dart
│   │   ├── order.dart
│   │   ├── payment_method.dart
│   │   ├── review.dart
│   │   └── user_profile.dart
│   ├── theme/
│   │   ├── bookstore_tokens.dart   # Dart representation of bookstore_theme.json
│   │   └── bookstore_theme_data.dart# Material 3 ThemeData builder
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── data/
│   ├── contracts/                  # Abstract repository contracts (Interfaces)
│   │   ├── address_repository.dart
│   │   ├── admin_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── book_repository.dart
│   │   ├── cart_repository.dart
│   │   ├── order_repository.dart
│   │   ├── payment_method_repository.dart
│   │   ├── profile_repository.dart
│   │   ├── review_repository.dart
│   │   └── wishlist_repository.dart
│   └── mock/                       # In-memory reactive mock implementations
│       ├── mock_address_repository.dart
│       ├── mock_admin_repository.dart
│       ├── mock_auth_repository.dart
│       ├── mock_book_repository.dart
│       ├── mock_cart_repository.dart
│       ├── mock_database.dart       # Singleton demo database
│       ├── mock_order_repository.dart
│       ├── mock_payment_method_repository.dart
│       ├── mock_profile_repository.dart
│       ├── mock_review_repository.dart
│       └── mock_wishlist_repository.dart
├── features/                       # Vertical feature slices
│   ├── admin/                      # Dashboard, Book, Order & User management
│   ├── authentication/             # Splash, Onboarding, Login, Register, Forgot Password
│   ├── book_details/               # Luxury canvas, metadata panel, review breakdown
│   ├── cart/                       # Shipping progress, item list, totals, checkout CTA
│   ├── catalog/                    # Grid/list toggle, category filters
│   ├── checkout/                   # Address & payment selection, order confirmation
│   ├── home/                       # Greeting, search, hero banner, carousels
│   ├── orders/                     # Orders list and delivery tracking timeline
│   ├── profile/                    # Profile management, address/payment settings
│   ├── reviews/                    # Review cards, ratings distribution, review submission
│   ├── search/                     # Real-time search, filter & sort bottom sheets
│   └── wishlist/                   # Saved books, move to cart
├── providers/
│   └── app_providers.dart          # Riverpod DI & reactive state streams
└── shared/
    └── widgets/                    # Reusable design system component library
```

## State Management & Dependency Injection

- **Framework**: `flutter_riverpod` (^3.4.3).
- **Inversion of Control**: All screens depend only on abstract Repository contracts exposed via Riverpod providers (`authRepositoryProvider`, `bookRepositoryProvider`, `cartRepositoryProvider`, etc.).
- **Reactive Streams**: Screens subscribe to reactive `StreamProvider` instances (`cartStreamProvider`, `wishlistStreamProvider`, `ordersStreamProvider`, `allBooksStreamProvider`) allowing immediate, reactive UI updates whenever cart quantities, wishlist state, or search filters change.
- **Teammate Integration**: To replace mock repositories with production Firebase or REST API implementations, teammates only need to bind their implementation class in `lib/providers/app_providers.dart` without editing a single UI widget or screen.

## Routing Architecture

- **Engine**: `go_router` (^18.0.2).
- **Bottom Navigation Shell**: Uses `StatefulShellRoute.indexedStack` to preserve state across customer tabs (`/home`, `/explore`, `/wishlist`, `/cart`, `/profile`).
- **Deep Linking**: Full support for parameterized routes like `/book/:id`, `/orders/:id`, and `/order-confirmation/:orderId`.
- **Root Navigator**: Subordinate screens, dialogs, and bottom sheets are cleanly separated from tab navigation bars to ensure unobstructed checkout and reading experiences.
