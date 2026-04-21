# 🦁 AdaVizion: Interactive University Engagement Platform

> **Transforming Euthenics & Orientation into an Immersive Campus Adventure.**

![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-In_Development-orange?style=for-the-badge)

## About The Project

**AdaVizion** is a mobile-first EdTech application designed to revolutionize the student onboarding experience at **Enverga University**. 

By digitizing **Euthenics courses** and university orientation, AdaVizion turns passive learning into an active, location-based adventure. Students don't just "read" about university history—they explore it, unlock it, and earn achievements for mastering it.

### Core Mission
To foster a deeper connection between the student body and the university’s history through **gamification**, **interactive discovery**, and **digital storytelling**.

---

## Key Features

### Campus Quest (Location-Based)
- **Digital Scavenger Hunts:** Unlock lore by physically visiting historical landmarks on campus.
- **Interactive Maps:** Real-time navigation to key university locations.

### Knowledge Hub (Gamified Learning)
- **Trivia Challenges:** Test your knowledge of Enverga history to earn points.
- **Euthenics Modules:** Interactive lessons that replace traditional static reading materials.

### Achievement System
- **Digital Badges:** Earn rewards for completing orientation tasks and history milestones.
- **Social Flex:** Share banners and badges directly to social media.

---

## Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Cross-platform Mobile)
* **Language:** Dart
* **Architecture:** Feature-based / Clean Architecture (Planned)
* **State Management:** Provider (Planned)
* **Tools:** VS Code, Android Studio (Emulator)

---

## Environment Setup Guide (Windows)

To contribute to this project, you must set up your development environment correctly.

> **Official Reference:** We follow the [Flutter Windows Quick Start Guide](https://docs.flutter.dev/install/quick).

### 1. Flutter SDK Installation
1.  Download the **Flutter SDK (Stable)** zip file from the official website.
2.  Extract the folder to `C:\src\flutter`.
    * ** IMPORTANT:** Do *not* install in `C:\Program Files` (Windows permissions will block updates).
3.  **Add to Path:**
    * Press `Windows Key` and type "env". Select **Edit environment variables for your account**.
    * Under "User variables", find `Path` and click **Edit**.
    * Click **New** and paste: `C:\src\flutter\bin`.
    * Click OK to save.

### 2. Android Studio Setup (For Toolchain)
1.  Download and install **Android Studio** (Standard settings).
2.  Open Android Studio.
3.  **Install Command-line Tools:**
    * Click **More Actions** (3 dots) > **SDK Manager**.
    * Go to the **SDK Tools** tab in the middle.
    * Check the box for **Android SDK Command-line Tools (latest)**.
    * Click **Apply** and let it download.

### 3. VS Code Configuration
1.  Install **Visual Studio Code**.
2.  Go to the Extensions tab (`Ctrl+Shift+X`).
3.  Search for and install the **Flutter** extension (This automatically installs Dart).

### 4. Final Verification & Licenses
Open your VS Code terminal and run:
```bash
flutter doctor --android-licenses

```

* Type `y` and hit Enter for every license prompt.
* Finally, run `flutter doctor`. You should see all Green Checks ✅.

---

## Running the Project

### 1. Clone the Repository

```bash
git clone [https://github.com/pak-pow/AdaVizion.git](https://github.com/pak-pow/AdaVizion.git)

```

### 2. Install Dependencies

```bash
cd AdaVizion
flutter pub get

```

### 3. Launch Emulator

* Open Android Studio > Virtual Device Manager.
* Start your **Pixel 7** (or similar) emulator.

### 4. Run App

```bash
flutter run

```

---

## Contributors & Core Team

This project is developed by the AdaVizion Team.

| Role | Name | GitHub |
| --- | --- | --- |
| **Mobile Developer** | **Vincent Aguirre** | [@pak-pow](https://github.com/pak-pow) |
| **Web Developer** | **Neil Tagle** | [@neophiles](https://github.com/neophiles) |
| **UI / UIX Designer** | **Raily Laurel** | [@DaRhyliee](https://www.google.com/search?q=https://github.com/username) |
| **Database Developer** | **Ace Gamitin** | [@acevincent05](https://github.com/acevincent05)|
| **Mobile Developer** | **Kyla Dequito** | [@Lapotski](https://github.com/Lapotski) |

---

## 📄 License

Proprietary Software. All rights reserved.

