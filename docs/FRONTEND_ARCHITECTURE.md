# Frontend Architecture Documentation

## Overview

The Aptech Book Store application frontend is architected as an enterprise-grade Flutter presentation system designed with strict separation of concerns, high visual fidelity, modular features, and a decoupled repository pattern.

## Directory structure

- `lib/app/router/`: GoRouter tab shell, deep links and authentication/admin guards.
- `lib/core/models/`: domain entities.
- `lib/core/theme/`: canonical premium tokens and bundled-font theme.
- `lib/data/contracts/`: repository interfaces.
- `lib/data/firestore/`: Firebase Auth, Firestore codecs, live repositories and Firestore transactions.
- `lib/features/`: customer, authentication, checkout, account and administrator screens.
- `lib/providers/app_providers.dart`: Riverpod dependency wiring and account-scoped streams.
- `lib/shared/widgets/`: reusable design system components.
- `firebase_tests/`: isolated emulator tests for access rules, transactions, pricing and aggregates.
- `firestore.rules`: server-enforced access, price/stock validation, review aggregation and role protection.

## State Management & Dependency Injection

- **Framework**: `flutter_riverpod` (^3.4.3).
- **Inversion of Control**: All screens depend only on abstract Repository contracts exposed via Riverpod providers (`authRepositoryProvider`, `bookRepositoryProvider`, `cartRepositoryProvider`, etc.).
- **Reactive Streams**: Screens subscribe to reactive `StreamProvider` instances (`cartStreamProvider`, `wishlistStreamProvider`, `ordersStreamProvider`, `allBooksStreamProvider`) allowing reactive UI updates whenever Firestore snapshots or search filters change.
- **Firebase integration**: Production repositories are bound in `app_providers.dart`; customer listeners are scoped to the current UID and disposed on account changes. There is no runtime mock fallback.

## Routing Architecture

- **Engine**: `go_router` (^18.0.2).
- **Bottom Navigation Shell**: Uses `StatefulShellRoute.indexedStack` to preserve state across customer tabs (`/home`, `/explore`, `/wishlist`, `/cart`, `/profile`).
- **Deep Linking**: Full support for parameterized routes like `/book/:id`, `/orders/:id`, and `/order-confirmation/:orderId`.
- **Root Navigator**: Subordinate screens, dialogs, and bottom sheets are cleanly separated from tab navigation bars to ensure unobstructed checkout and reading experiences.
