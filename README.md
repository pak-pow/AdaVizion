# EUventure: Interactive University Exploration Platform

![Flutter](https://img.shields.io/badge/Built_with-Flutter-blue?style=for-the-badge&logo=flutter&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.0.0--alpha-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Alpha_Testing-darkgreen?style=for-the-badge)

## 🦁 About The Project

**EUventure** is a mobile-first web application designed to modernize the orientation experience at **Manuel S. Enverga University Foundation (MSEUF)**. By gamifying the **EU111: University and I** course, the platform shifts traditional classroom lectures into a hands-on, on-site exploration of the campus.

## 🎯 Core Objectives

1. ### Enhance Euthenics Education

    Serve as a gamified and interactive extension to the official MSEUF [website](https://mseuf.edu.ph) and [student handbook](https://mseuf.edu.ph/osas/announcements/is-now-available-250219110640).

2. ### Promote Facility Awareness

    Encourage students to physically interact with campus landmarks and history.

3. ### Improve Engagement

    Use gamification and achievement-based systems to increase student retention and learning outcomes.

## ✨ Key Features

1. ### Campus Landmarks & QR Scanner

    - **Physical Check-ins**: Use the integrated QR scanner to verify your presence at designated campus locations.

    - **Exploration Progress**: Track visited sites through a visual checklist that differentiates between unlocked and "padlocked" landmarks.

    - **XP Reward**: Automatically earn a fixed amount of XP for every new landmark successfully scanned.

2. ### Fun Facts

    - **Instant Lore**: Unlock bite-sized historical snippets or engaging trivia immediately after scanning a landmark.

    - **Fallback Content**: Provides general MSEUF trivia if a specific location lacks dedicated historical data.

3. ### Quizzes

    - **Gatekeeping**: Access to assessments is restricted until you visit enough landmarks.

    - **Academic Integrity**: Correct answers are only shown immediately after submission. Quizzes are limited to a single graded submission per module to ensure assessment validity.

    - **XP Reward**: Automatically earn a fixed amount of XP for every new quiz successfully submitted.

4. ### Dashboard

    - **Real-time Summary**: View current level, total XP, total quiz points, and a count of visited landmarks immediately upon login.

    - **Digital Badges**: Dynamically earn and display `EXPLORER` or `SCHOLAR` badges as you hit progress thresholds

5. ### Profile

    - **Personalization**: Upload and manage your student profile picture, powered by Supabase Storage.

    - **Academic Info**: Directly update your name, year level, program, and specialization to ensure your student record is accurate.

    - **Account Security**: Full password management and secure session logout.

## 🛠️ Tech Stack

1. ### Frontend

    | Category | Technology |
    | --- | --- |
    | **Language** | [Dart](https://dart.dev/docs) |
    | **Framework** | [Flutter](https://flutter.dev/) |
    | **HTTP Client** | [http](https://pub.dev/packages/http) |
    | **Scanner** | [mobile_scanner](https://pub.dev/packages/mobile_scanner) |
    | **Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
    | **Media** | [image_picker](https://pub.dev/packages/image_picker) |
    | **Design** | [cupertino_icons](https://pub.dev/packages/cupertino_icons) |

2. ### Backend

    | Category | Technology |
    | --- | --- |
    | **Runtime** | [Node.js](https://nodejs.org/en) |
    | **Language** | [TypeScript](https://www.typescriptlang.org/docs/) |
    | **Framework** | [Express.js](https://expressjs.com/) |
    | **Database** | [PostgreSQL](https://www.postgresql.org/docs/) |
    | **ORM** | [Prisma](https://www.prisma.io/) |
    | **Storage** | [Supabase](https://supabase.com/docs/guides/storage) |
    | **File Handling** | [Multer](https://www.npmjs.com/package/multer) |
    | **Authentication** | [JWT](https://jwt.io/introduction), [Bcrypt](https://www.npmjs.com/package/bcrypt) |
    | **Validation** | [Zod](https://zod.dev/) |
    | **Utilities** | [qrcode](https://www.npmjs.com/package/qrcode) |
    | **CORS** | [cors](https://www.npmjs.com/package/cors) |
    | **Config** | [Dotenv](https://www.npmjs.com/package/dotenv) |

4. ### Shared Tools & DevOps

    | Category | Technology |
    | --- | --- |
    | **Version Control** | [Git](https://git-scm.com/), [GitHub](https://github.com/) |
    | **Testing** | [Postman](https://www.postman.com/), [Thunder Client](https://www.thunderclient.com/) |
    | **IDE** | [VS Code](https://code.visualstudio.com/) |
    | **Deployment** | [Vercel](https://vercel.com/), [Render](https://render.com/) |

## 💻 Download Prerequisite Software

> We follow the [Flutter Windows Quick Start Guide](https://docs.flutter.dev/install/quick).

1. ### Install Git for Windows

    Download and install the latest version of [Git for Windows](https://git-scm.com/downloads/win).

2. ### Download and install Visual Studio Code

    To quickly install Flutter, then edit and debug your apps, [install and set up Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview).

## 🪽 Install and set up Flutter

> If you prefer to manually install Flutter, follow the instructions in [Install Flutter manually](https://docs.flutter.dev/install/manual).

1. ### Launch VS Code

2. ### Add the Flutter extension to VS Code

    To add the Dart and Flutter extensions to VS Code, visit the [Flutter extension's marketplace](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) page, then click **Install**. If prompted by your browser, allow it to open VS Code.

3. ### Install Flutter with VS Code

    - Open the command palette in VS Code by pressing `Control` + `Shift` + `P`.

    - In the command palette, type flutter.

    - Select **Flutter: New Project**.

    - VS Code prompts you to locate the Flutter SDK on your computer. Select **Download SDK**.

    - When the **Select Folder for Flutter SDK** dialog displays, choose where you want to install Flutter.

    - Click **Clone Flutter**.

    - Click Add SDK to PATH.

    - Restart VS Code to ensure that Flutter is available in all terminals.

## 🔒 Database & Backend Setup

1. ### Install Dependencies

    Ensure you have [Node.js](https://nodejs.org/en/download/current) installed, then run:
    
    ```bash
    cd backend
    npm install
    ```

2. ### Environment Configuration

    Duplicate `.env.example` as `.env` in `/backend`:
    
    ```env
    DATABASE_URL="request from neophiles"
    SUPABASE_URL="request from neophiles"
    SUPABASE_SERVICE_ROLE_KEY="request from neophiles"
    PORT=3000
    JWT_SECRET="request from neophiles or generate your own"
    FRONTEND_ORIGIN="http://localhost:5000"
    ```

3. ### Initialize Prisma and Sync Schema

    ```bash
    npx prisma generate
    npx prisma migrate dev
    ```

4. ### Run Backend

    ```bash
    npm run dev
    ```

## 📱 Frontend Setup

1. ### Install Dependencies

    ```bash
    cd frontend
    flutter pub get
    ```

2. ### Run Frontend

    ```bash
    flutter run -d chrome --web-port 5000
    ```

## 🤩 Contributors & Core Team

This project is developed by the AdaVizion team.

| Role | Name | GitHub |
| --- | --- | --- |
| **Project Lead, UI/UX Designer** | **Raily Laurel** | [@DaRhyliee](https://github.com/DaRhyliee) |
| **Lead Developer** | **Vincent Aguirre** | [@pak-pow](https://github.com/pak-pow) |
| **Frontend Developer, Researcher** | **Kyla Dequito** | [@Lapotski](https://github.com/Lapotski) |
| **Backend Developer** | **Neil Tagle** | [@neophiles](https://github.com/neophiles) |
| **Data Specialist, Researcher** | **Ace Gamitin** | [@acevincent05](https://github.com/acevincent05)|

## ✒️ License

Proprietary Software. Copyright (c) 2026 AdaVizion. All rights reserved.

This software and associated documentation files are the exclusive property of AdaVizion. Unauthorized copying, modification, distribution, or use of this software via any medium is strictly prohibited.
