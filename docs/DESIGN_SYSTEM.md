# Bookstore Premium Design System

## Canonical Specification

The visual identity is defined in `assets/theme/bookstore_theme.json` and mirrored in `lib/core/theme/bookstore_tokens.dart` and `lib/core/theme/bookstore_theme_data.dart`.

### Visual Identity
- **Design Philosophy**: Warm editorial luxury, reminiscent of modern boutique literary establishments and refined publishing houses.
- **Surface Quality**: Warm ivory, porcelain surfaces, and soft champagne gold accents.
- **Typography Philosophy**: High-contrast pairings between classic display serifs (`Cormorant Garamond`) for titles and headings, and crisp, legible sans-serifs (`Inter`) for body copy, badges, and controls.

## Color Tokens

| Token | Hex Value | Usage |
| :--- | :--- | :--- |
| `background` | `#FFFCF8` | Main scaffold surface; warm ivory |
| `backgroundWarm` | `#F5EBDD` | Top canvas gradient and ambient glows |
| `surface` | `#FFFFFF` | Primary card and bottom sheet background |
| `surfaceWarm` | `#FAF4EB` | Subtle containers, inactive badges |
| `surfaceMuted` | `#F4F0EA` | Input field fills, stepper backgrounds |
| `primary` | `#C99442` | Primary brand champagne gold CTA, ratings, active indicators |
| `primaryDark` | `#A76E24` | Contrast gold for badges, borders |
| `primaryLight` | `#E6BF82` | Highlights, subtle borders |
| `accentSoft` | `#F9EEDC` | Light warm badge backgrounds |
| `textPrimary` | `#191C24` | High-contrast dark ink typography |
| `textSecondary` | `#777A80` | Subtle metadata, author labels, secondary notes |
| `textMuted` | `#A4A4A8` | Placeholders, inactive dots, timestamps |
| `border` | `#EAE5DD` | Subtle card borders, input borders |
| `divider` | `#EEEAE4` | Section separators |
| `success` | `#39815B` | Free shipping unlocked, confirmation status |
| `error` | `#CC4545` | Deletions, validation warnings, unread badges |
| `warning` | `#D99B26` | In-progress orders |
| `rating` | `#F5AE21` | Star rating glyphs |

## Typography Scale

- **Display Large**: 34pt, Cormorant Garamond, Bold
- **Display Medium**: 28pt, Cormorant Garamond, Bold
- **Headline Large / Book Title**: 24-26pt, Cormorant Garamond, Bold
- **Section Title**: 18-20pt, Inter, Bold
- **Body Large**: 16pt, Inter, Regular
- **Body Medium**: 14pt, Inter, Regular / Medium
- **Body Small / Captions**: 12pt, Inter, Regular (Secondary text)
- **Label / Badges**: 11-12pt, Inter, Semibold

## Component Geometries

- **Book Cover Aspect Ratio**: `0.68`
- **Book Cover Border Radius**: `9.0`
- **Card Border Radius**: `18.0`
- **Input Border Radius**: `16.0`
- **Button Border Radius**: `15.0`
- **Pill Border Radius**: `999.0`
- **Primary Button Height**: `54.0`
- **Bottom Navigation Height**: `72.0`
- **Horizontal Screen Padding**: `20.0`
