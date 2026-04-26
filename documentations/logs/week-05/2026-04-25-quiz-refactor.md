| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-25 |
| **Project** | EUventure |
| **Topic** | Quiz Module (Core Implementation, Bug Fixes & Navigation Refactor) |
| **Developer** | Dequito |
| **Tags** | `Flutter`, `Frontend`, `Quiz`, `Refactor`, `UI`, `Bug Fixes`, `Dev Log` |

# DEV LOG: WEEK 5 - DAY 1

## Core Objective

Refactoring the quiz feature structure for easily maintainable code and enforce DRY principles. UI changes based on UI designer's requests.

## 1. Structure

Refactored from 3 monolithic screens into a proper feature folder:

*BEFORE*

```
quiz/
├── quiz_list_screen.dart
├── quiz_taking_screen.dart
└── quiz_result_screen.dart
```

---

*AFTER*

```
quiz/
├── quiz_constants.dart
├── quiz_list_screen.dart
├── models/
│   └── quiz_model.dart
├── widgets/
│   ├── quiz_accordion_card.dart
│   ├── quiz_detail_panel.dart
│   └── shared/
│       └── quiz_error_state.dart
└── views/
    ├── quiz_taking_view.dart
    └── quiz_result_view.dart
```


## 2. Changes

**DRY / constants**
- Extracted all `static const` color definitions into `quiz_constants.dart` — were copy-pasted across 3 files

**Models**
- Moved `QuizState` enum and `resolveQuizState()` / `buildQuizHint()` out of the list screen into `quiz_model.dart`
- Added `QuizResult` wrapper class to replace scattered `result['progress']['xp']['earned'] as int? ?? 0` cast chains in the result screen

**Widgets**
- Extracted `QuizAccordionCard` and `QuizDetailPanel` out of the 400-line list screen
- Unified two separate error UIs (full-screen and inline card) into one `QuizErrorState` with a `compact` flag

**Bug fix**
- After completing a quiz and returning via result screen buttons, the accordion was showing the updated score but the pill still said "Take Quiz" instead of the score — detail cache was not being invalidated
- Fixed by adding `onQuizExited` callback that clears `_detailData[quizId]`, collapses the accordion, and re-fetches the list on return

**UI**
- Gradient on the list screen header adjusted to match the profile banner, per designer feedback ("match to profile banner")

### Known TODOs
- Reward toasts (level-up, achievements) are implemented via `SnackBar` — flagged for replacement once a proper notification system is in place
- Question sort by `question_id` is a temporary workaround for inconsistent server/cache ordering