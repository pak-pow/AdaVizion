| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-27 |
| **Project** | EUventure |
| **Topic** | Global Color Constants (`AppColors`) |
| **Developer** | Dequito |
| **Tags** | `Flutter`, `Frontend`, `Theming`, `Refactor`, `DRY`, `Dev Log` |

# DEV LOG: WEEK 5 - DAY 2

## Core Objective

Consolidate all screen-level color definitions scattered across the codebase into a single `AppColors` class — eliminating copy-pasted hex values and laying the groundwork for future light/dark mode theming.

## 1. Problem

Every screen defined its own private color constants with no shared source of truth:

| Screen | Definition style |
| :--- | :--- |
| Auth | `static const _maroon = Color(0xFF7A1D1D)` |
| Dashboard | `static const _maroon = Color(0xFF7A1D1D)` |
| Landmarks | `const kLandmarkMaroon = Color(0xFF7A1D1D)` |
| QR Code | `static const Color maroon = Color(0xFF7A1D1D)` |
| Quiz | `const kQuizMaroon = Color(0xFF7A1D1D)` |

The same hex values were copy-pasted 5+ times. A single brand color change would require hunting down every file.

## 2. Structure

New file added at:

```
lib/
└── theme/
     └── app_colors.dart
```

## 3. Changes

**Consolidation**
- Merged color constants from `auth`, `dashboard`, `landmarks`, `qr_code`, and `quiz` screens into one `abstract final class AppColors`
- Grouped into semantic sections: Brand Maroon, Neutrals, Accents, Success/Pass, Error/Fail, Fun Fact card palette

**Naming**
- Dropped screen-prefixed names (`kQuizMaroon`, `kLandmarkMaroon`) in favour of intent-based names (`AppColors.maroon`, `AppColors.funFactGreen`)


## 4. Known TODOs

- When light/dark mode is introduced, `AppColors` splits into `AppColorsLight` / `AppColorsDark` and gets consumed by `ThemeData` in a new `app_theme.dart` — no call-site changes needed beyond that