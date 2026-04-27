| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-27 |
| **Project** | EUventure |
| **Topic** | QR Code Screen (Refactor, DRY, Documentation & Error Handling) |
| **Developer** | Dequito |
| **Tags** | `Flutter`, `Frontend`, `QR Code`, `Refactor`, `DRY`, `Documentation`, `Dev Log` |

# DEV LOG: WEEK 5 - DAY 2

## Core Objective

Refactoring the QR code scanning screen from a single monolithic file into a proper feature folder structure to enforce DRY principles, improve maintainability, and add comprehensive `///` documentation throughout.

## 1. Structure

Refactored from one 500-line screen file into a focused feature folder:

*BEFORE*

```
screens/
└── qr_code_screen.dart
```

---

*AFTER*

```
screens/
└── qr_code/
    ├── qr_code_screen.dart
    ├── qr_code_constants.dart
    ├── utils/
    │   └── scan_error_handler.dart
    └── widgets/
        ├── scan_dialogs.dart
        ├── scan_overlay_painter.dart
        ├── scanner_footer.dart
        └── permission_denied_view.dart
```

## 2. Changes

**DRY / constants**
- Extracted `_maroon`, `_maroonDark`, `_headerGrey`, and `_scanAreaSize` into `qr_code_constants.dart` as `static const` fields — were previously copy-pasted inline across the screen and would have been duplicated again in extracted widgets

**Widgets**
- Extracted `_ScanOverlayPainter` (was a private class at the bottom of the screen file) into `scan_overlay_painter.dart` — now properly public and documented
- Extracted the torch button + instruction label into `ScannerFooter` — removes ~40 lines of nested `Container`/`Column`/`Row` from `_buildBody`
- Extracted `_buildPermissionDeniedUI` into `PermissionDeniedView` — standalone stateless widget with an `onRetry` callback parameter

**Dialogs**
- Moved all five dialog methods (`_showSuccessDialog`, `_showInvalidQrDialog`, `_showAlreadyVisitedDialog`, `_showErrorDialog`, `_showSafetyReminderDialog`) plus `_showScanDialog`, `_dialogButton`, and `_closeDialogAnd` into `ScanDialogsMixin`
- Private helper widgets `_DialogHeader`, `_FunFactCard`, and `_XpPill` extracted from inline `AlertDialog` builds into named widget classes inside `scan_dialogs.dart`
- Dialog methods now accept explicit callbacks (`onReset`, `onViewLandmark`) instead of directly calling screen methods — mixin has no knowledge of navigation targets, imports of `LandmarkDetailView`, `DashboardScreen`, and `LandmarkSummary` removed from the mixin entirely

**Error handling**
- Extracted `_onScanError` string-matching logic into `ScanErrorHandler` — pure static utility, no state, fully isolated from widget tree
- Considered switching to HTTP status code matching (`ApiError`) but reverted — `handleBackendError` in `ApiConfig` throws plain `Exception` and changing it risked breaking error handling in other screens; string matching against the existing backend messages is stable and sufficient

**Documentation**
- Added `///` doc comments to every public class, constructor, method, and parameter across all new files
- Platform-specific caveats preserved in context: web `scanWindow` limitation, web permission-denial path via `errorBuilder` vs controller listener

**`qr_code_screen.dart` result**
- Reduced from ~500 lines to ~180 lines
- State class now only owns: camera lifecycle, permission state, scan handling, loading state, and navigation

## 3. Known TODOs

- `ApiConfig.handleBackendError` still throws plain `Exception` — if structured error routing (`ApiError`) is needed app-wide in the future, that's the one change required; `ScanErrorHandler` is already written to accept it with a one-line swap
- Reward toasts (level-up, achievements) from `visitLandmark` response are not yet surfaced in the success dialog — `progress['level']['did_level_up']` and `new_achievements` are present in the API response but currently unused