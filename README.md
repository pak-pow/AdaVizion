# AdaVizion: Interactive University Exploration Platform

> **Transforming Euthenics & Orientation into an Immersive Campus Adventure.**

![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-In_Development-orange?style=for-the-badge)

## About The Project

**EUventure** is a mobile-first web application designed to modernize the orientation experience at **Manuel S. Enverga University Foundation (MSEUF)**. By gamifying the **EU111: University and I** course, the platform shifts traditional classroom lectures into a hands-on, on-site exploration of the campus.

## 🎯 Core Objectives

- **Enhance Euthenics Education:** Transform static website and handbook platform into interactive discovery.
- **Promote Facility Awareness:** Encourage students to physically interact with campus landmarks and history.
- **Improve Engagement:** Use gamification and achievement-based systems to increase student retention and learning outcomes.

## ✨ Key Features

### 1. University Landmarks & QR Scanner

- **Physical Check-ins:** Use the integrated QR scanner to verify your presence at designated campus locations.
- **Exploration Progress:** Track visited sites through a visual checklist that differentiates between unlocked and "padlocked" landmarks.
- **XP Allocation:** Automatically earn a fixed amount of XP for every new landmark successfully scanned.

### 2. Fun Facts & Trivia

- **Instant Lore:** Unlock bite-sized historical snippets or engaging trivia immediately after scanning a landmark.
- **Fallback Content:** Provides general MSEUF trivia if a specific location lacks dedicated historical data.

### 3. Progressive Quizzes

- **XP Gatekeeping:** Access to formal curriculum assessments is restricted until you gather enough XP from campus exploration.
- **Academic Integrity:** Limited to a single graded submission per module to ensure assessment validity.

### 4. Student Dashboard & Profile

- **Real-time Summary:** View total XP, quiz points, and a count of visited landmarks immediately upon login.
- **Digital Badges:** Dynamically earn and display "Explorer" or "Scholar" badges as you hit progress thresholds

## 🛠️ Tech Stack

| Category | Technology |
| --- | --- |
| **Frontend** | [Dart](https://dart.dev/docs), [Flutter](https://flutter.dev/) |
| **Backend** | [TypeScript](https://www.typescriptlang.org/docs/), [Express.js](https://expressjs.com/) |
| **ORM** | [Prisma](https://www.prisma.io/) |
| **Database** | [PostgreSQL](https://www.postgresql.org/docs/) |
| **Validation** | [Zod](https://zod.dev/) |
| **Security** | [JWT](https://jwt.io/introduction) |
| **Development** | [VS Code](https://code.visualstudio.com/), Web Browser |
| **Test** | [Postman](https://www.postman.com/) |
| **Deployment** | [Vercel](https://vercel.com/) |

## ⚙️ Environment Setup Guide (Windows)

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

## 🔒 Database & Backend Setup

To contribute to the backend or sync your local environment with the cloud database, follow these steps:

### 1. Install Dependencies

* Ensure you have [Node.js](https://nodejs.org/en/download/current) installed, then run:

```bash
cd backend
npm install
```

### 2. Environment Configuration

* Create a `.env` file in `/backend`.

```env
DATABASE_URL="Past your connection string (Ask neophiles for it)"
```

### 3. Initialize Prisma

```bash
npx prisma generate
```

### 4. Sync Schema to the Cloud Database

```bash
npx prisma migrate dev
```

### 5. Seed Initial Data (Landmarks, Quizzes, and Achievements)

```bash
npm run seed
```

### 6. Run Backend

```bash
npm run dev
```

## 📱 Frontend Setup

### 1. Clone the Repository

```bash
git clone https://github.com/pak-pow/AdaVizion.git
```

### 2. Install Dependencies

```bash
cd AdaVizion
flutter pub get
```

### 3. Run App

```bash
flutter run
```

## 🤩 Contributors & Core Team

This project is developed by the AdaVizion Team.

| Role | Name | GitHub |
| --- | --- | --- |
| **Project Lead, UI/UX Designer** | **Raily Laurel** | [@DaRhyliee](https://github.com/DaRhyliee) |
| **Lead Developer** | **Vincent Aguirre** | [@pak-pow](https://github.com/pak-pow) |
| **Frontend Developer** | **Kyla Dequito** | [@Lapotski](https://github.com/Lapotski) |
| **Backend Developer** | **Neil Tagle** | [@neophiles](https://github.com/neophiles) |
| **Data Specialist, Researcher** | **Ace Gamitin** | [@acevincent05](https://github.com/acevincent05)|

## ✒️ License

Proprietary Software. Copyright (c) 2026 AdaVizion. All rights reserved.