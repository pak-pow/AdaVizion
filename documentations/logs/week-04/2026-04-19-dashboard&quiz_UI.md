---
date: 2026-04-19
project: EUventure
topic: Gamified Quiz Interface & Dynamic State Rendering
Tags:
  - "[[Flutter]]"
  - "[[Dart]]"
  - "[[Frontend]]"
  - "[[Dev Log]]"
  - "[[UI Design]]"
developer: Aguirre
---
# 📝 DEV LOG: EUVENTURE - GAMIFIED QUIZ INTERFACE & DYNAMIC STATES

**Core Objective:** Translate the high-fidelity Figma designs for the Quiz Screen into a highly modular, state-driven Flutter UI. The screen must dynamically adapt its visual elements (colors, icons, text) based on whether a quiz is locked, unlocked, or completed.

## 1. Architectural Upgrade: The `QuizState` Enum Pattern
To avoid duplicating card code and creating a messy widget tree, the UI was engineered around a central state machine.
* **Implementation:** Introduced the `QuizState` enum (`locked`, `unlocked`, `completed`).
* **Dynamic Rendering:** The `_buildQuizCard` method accepts a dictionary of quiz data and injects the state into a `_buildInnerButtonContent()` helper. 
* **Logic:** * If `QuizState.locked`: The button container turns grey (`Colors.grey.shade400`) and renders a white `Icons.lock_outline`.
  * If `QuizState.unlocked`: The container turns `_maroonDark` and renders "Take Quiz".
  * If `QuizState.completed`: The container stays `_maroonDark` and renders "Completed".

## 2. UI Polish: Figma Parity
The visual hierarchy was strictly matched to the provided UI mockups.
* **The Flush Header:** Designed a `LinearGradient` header (`_gradientTop` to `_maroon`) with sharp top corners and rounded bottom corners (`Radius.circular(12)`). This allows it to sit perfectly flush against the light grey (`#F5F5F5`) `AppBar`, creating a seamless, immersive header.
* **The "Go Back" Footer:** Implemented a heavily styled, high-contrast footer. The primary action button utilizes an `OutlinedButton` with a 1.5px `_maroonDark` border and a bold `w900` font weight to anchor the bottom of the scroll view.

## 3. Dashboard Routing Integration
The isolated `QuizScreen` was wired into the main application flow.
* **Implementation:** Replaced the temporary `QuizScreenPlaceholder` in `dashboard_screen.dart`.
* **Routing:** Attached `Navigator.push()` to the primary "Take Quiz" pill button in the Top Navigation Bar, ensuring the user can access the quiz interface from any state on the dashboard. The custom back button in the Quiz screen utilizes `Navigator.pop()` to safely return without breaking the navigation stack.

