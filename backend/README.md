# EUventure Backend Documentation

Welcome to the backend documentation for EUventure! The APIs power the interactive gamification, student tracking, and academic assessment features of the platform.

## 🏗️ Architecture

The backend has been completely overhauled to follow a strictly typed **Route-Controller-Service-Repository (RCSR)** architecture. This ensures a clean separation of concerns:

| Layer | Description |
| :--- | :--- |
| **Routes** | Defines endpoints and mounts the `authenticateToken` middleware. |
| **Controllers** | Handles request validation using Zod and coordinates HTTP responses. |
| **Services** | Contains pure business logic, such as XP calculations, evaluating quiz correctness, and processing reusable `checkAchievements` triggers. |
| **Repositories** | Manages the direct data access layer via Prisma. |

## ✨ Core Features & Technical Decisions

### 1. Security & Authentication

* **JWT & Passwords:** Uses `jsonwebtoken` for secure student sessions and `bcrypt` (10 salt rounds) for password hashing. Passwords are destructured and never returned in JSON payloads.

* **Validation Layer:** Implements schema-driven validation using **Zod** for type-safe request parsing, eliminating manual `if` checks.

* **MSEUF Restriction:** Registration enforces the `@student.mseuf.edu.ph` domain and validates data against real-world academic programs (`academic-maps.ts`).

### 2. Gamification & Data Integrity

* **Atomic Transactions:** Uses `prisma.$transaction` to ensure actions like recording a landmark visit and rewarding XP happen simultaneously and atomically.

* **Progressive Discovery:** Unvisited landmarks hide their `fun_fact` and `description` from the student until successfully scanned.

* **Granular Tracking:** Quizzes track individual `is_correct` answers, `passing_score`, and `max_score` for detailed student feedback.

### 3. Centralized Error Handling

We utilize a domain-aware centralized error handling system (`lib/error-handler.ts`). It catches Zod validation errors and Prisma unique constraint codes (`P2002`) and standardizes them into a consistent JSON structure for the frontend:

```json
{
  "type": "DOMAIN_TYPE",
  "code": "ERROR_CODE",
  "message": "Human-readable description"
}
```

## 🗺️ API Routes Reference

All sensitive routes require a valid JWT passed as a `Bearer {token}` in the Authorization header.

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/students` | Fetches a list of all registered students. Requires authentication. |
| `POST` | `/students/register` | Registers a new student, hashes their password, enforces MSEUF email constraints, and automatically initializes their `Progress` record. |
| `POST` | `/students/login` | Authenticates a student via password comparison and returns a JWT session token. |
| `GET` | `/students/me` | Fetches the currently authenticated student's profile, including their XP progress and earned achievements. |
| `GET` | `/landmarks` | Fetches the landmark checklist. Visibility of facts/descriptions is conditionally hidden if `is_visited: false`. |
| `GET` | `/landmarks/:id` | Fetches details for a specific landmark. Secures `qr_string` and `fun_fact` from unvisited users. |
| `POST` | `/landmarks/:id/visit` | Verifies a QR scan, checks for duplicate visits, saves the visit, and automatically updates the student's XP. |
| `GET` | `/quizzes` | Returns a list of all quizzes, including XP lock status, remaining XP needed to unlock, and completion history. |
| `GET` | `/quizzes/:id` | Fetches a specific quiz and its question list. Includes the student's previous score if the quiz is already completed. |
| `POST` | `/quizzes/:id/submit` | Evaluates quiz answers for correctness, calculates the score, updates XP, and checks for newly unlocked achievements |
| `GET` | `/achievements` | Returns all available achievement badges in the system, utilizing the `is_unlocked` flag to dynamically display which ones the authenticated student has earned. |

## 🗄️ Database Schema Summary

The PostgreSQL database is managed via Prisma and includes the following primary models:
- `Student`, `Progress`
- `Landmark`, `LandmarksVisited`
- `Quiz`, `Question`, `QuizSubmission`
- `Achievement`, `AchievementsEarned`

*Note: All primary models include `created_at` and `updated_at` for audit trailing.*

## 🚀 Development Setup

To run the backend locally, ensure you have your .env configured and your database seeded.

### 1. Install dependencies

```Bash
cd backend
npm install
```

### 2. Configure environment

Create a file named `.env` in the `/backend` directory and populate it with the following variables:

```env
PORT=3000
DATABASE_URL="Insert connection string here"
JWT_SECRET="Insert secret key here"
```

***Note:** Please reach out to [@neophiles](https://github.com/neophiles) to get the actual `DATABASE_URL`. For the `JWT_SECRET`, you can ask for the team's shared key or generate your own random string for local testing.*

### 3. Generate Prisma client and sync schema

```Bash
npx prisma generate
npx prisma migrate dev
```

### 4.  Seed initial Landmarks, Quizzes, and Achievements

```Bash
npm run seed
```

### 5. Run the server with tsx watch mode for fast auto-restarts

```Bash
npm run dev
```

## API Test Matrix

To ensure the reliability of the **EUventure** API and the security of student data, the core responses and business logic were rigorously tested using **Postman**. These tests verify that our centralized error handling correctly maps domain-specific failures to a standardized JSON contract for the Flutter frontend.

| Case ID | Domain | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **01** | **Security** | Access protected route without token | `401 Unauthorized` | MISSING_TOKEN | "Access denied due to missing token" | ✅ Pass | ![Missing Token](../documentations/screenshots/api-tests/0-0-missing-token.png) |
| **02** | **Security** | Access with tampered or expired JWT | `401 Unauthorized` | INVALID_TOKEN | "Invalid or expired token" | ✅ Pass | ![Invalid Token](../documentations/screenshots/api-tests/0-1-expired-token.png) |
| **03** | **Auth** | Register with valid student data | `201 Created` | N/A | User saved | ✅ Pass | ![Register](../documentations/screenshots/api-tests/1-0-register.png) |
| **04** | **Auth** | Register already existing student | `409 Conflict` | DUPLICATE_STUDENT | "Student number or email already exists" | ✅ Pass | ![Duplicate Student](../documentations/screenshots/api-tests/1-4-duplicate-register.png) |
| **05** | **Auth** | Register with mismatching MSEUF email | `400 Bad Request` | VALIDATION_ERROR | "Email must match your student number" | ✅ Pass | ![Number and Email Mismatch](../documentations/screenshots/api-tests/1-1-number-and-email-mismatch.png) |
| **06** | **Auth** | Register with non-existent Program | `400 Bad Request` | VALIDATION_ERROR | "Please select a valid MSEUF academic program | ✅ Pass | ![Invalid Program](../documentations/screenshots/api-tests/1-2-invalid-program.png) |
| **07** | **Auth** | Register with invalid Specialization | `400 Bad Request` | VALIDATION_ERROR | "Invalid specialization for the selected program" | ✅ Pass | ![Invalid Specialization](../documentations/screenshots/api-tests/1-3-invalid-specialization.png) |
| **08** | **Auth** | Login with correct credentials | `200 OK` | N/A | JWT returned | ✅ Pass | ![Login](../documentations/screenshots/api-tests/2-0-login.png) |
| **09** | **Auth** | Login with wrong student number or password | `401 Unauthorized` | INCORRECT_CREDENTIALS | "Incorrect student number or password" | ✅ Pass | ![Incorrect Credentials](../documentations/screenshots/api-tests/2-1-incorrect-credentials.png) |
| **10** | **Profile** | Fetch authenticated student profile | `200 OK` | N/A | Profile data | ✅ Pass | ![Profile](../documentations/screenshots/api-tests/3-0-profile.png) |
| **11** | **Landmark** | Fetch all landmarks (New Student) | `200 OK` | N/A | List with `is_visited: false` | ✅ Pass | ![All Landmarks](../documentations/screenshots/api-tests/4-0-all-landmarks.png) |
| **12** | **Landmark** | Fetch details for unvisited landmark | `200 OK` | N/A | `fun_fact` & `qr_string` hidden | ✅ Pass | ![Unvisited Landmark](../documentations/screenshots/api-tests/4-1-locked-landmark.png) |
| **13** | **Landmark** | Scan QR / Visit landmark (First Time) | `200 OK` | N/A | Visit saved and achievement unlocked | ✅ Pass | ![Visit Landmark](../documentations/screenshots/api-tests/4-2-visit-landmark-with-achievement.png) |
| **14** | **Landmark** | Fetch details for visited landmark | `200 OK` | N/A | `fun_fact` revealed | ✅ Pass | ![Visited Landmark](../documentations/screenshots/api-tests/4-3-unlocked-landmark.png) |
| **15** | **Landmark** | Fetch a landmark ID that doesn't exist | `404 Not Found` | LANDMARK_NOT_FOUND | "Landmark not found" | ✅ Pass | ![Landmark Not Found](../documentations/screenshots/api-tests/4-4-landmark-not-found.png) |
| **16** | **Landmark** | Attempt to scan same QR again | `400 Bad Request` | DUPLICATE_LANDMARK | "Landmark already visited" | ✅ Pass | ![Duplicate Visit](../documentations/screenshots/api-tests/4-5-duplicate-visit.png) |
| **17** | **Quiz** | Fetch all quizzes | `200 OK` | N/A | List of quizzes with locked/unlocked status | ✅ Pass | ![All Quizzes](../documentations/screenshots/api-tests/5-0-all-quizzes.png) |
| **18** | **Quiz** | Fetch a quiz currently unlocked | `200 OK` | N/A | Quiz details and questions | ✅ Pass | ![Unlocked and Unanswered Quiz](../documentations/screenshots/api-tests/5-1-unlocked-and-unanswered-quiz.png) |
| **19** | **Quiz** | Attempt to access a locked quiz | `403 Forbidden` | QUIZ_LOCKED | "Quiz is locked. You need more XP to unlock it." | ✅ Pass | ![Locked Quiz](../documentations/screenshots/api-tests/5-2-locked-quiz.png) |
| **20** | **Quiz** | Submit valid quiz answers | `200 OK` | N/A | Score calculated and submission saved | ✅ Pass | ![](../documentations/screenshots/api-tests/5-3-submit-quiz.png) |
| **21** | **Quiz** | Fetch a previously completed quiz | `200 OK` | N/A | Quiz with `total_score` and questions with `is_correct` | ✅ Pass | ![Unlocked and Answered Quiz](../documentations/screenshots/api-tests/5-4-unlocked-and-answered-quiz.png) |
| **22** | **Quiz** | Fetch a quiz ID that doesn't exist | `404 Not Found` | QUIZ_NOT_FOUND | "Quiz not found" | ✅ Pass | ![Quiz Not Found](../documentations/screenshots/api-tests/5-5-quiz-not-found.png) |
| **23** | **Quiz** | Attempt to answer or resubmit an already completed quiz | `409 Conflict` | DUPLICATE_QUIZ | "Quiz already answered" | ✅ Pass | ![Duplicate Submission](../documentations/screenshots/api-tests/5-6-duplicate-submission.png) |
| **24** | **Achievement** | Fetch all student achievements | `200 OK` | N/A | List of locked/unlocked badges | ✅ Pass | ![All Achievements](../documentations/screenshots/api-tests/6-0-all-achievements.png) |
| **25** | **Server** | Server-side crash and other errors | `500 Internal Server Error` | INTERNAL_SERVER_ERROR | "Internal Server Error" | ✅ Pass | ![Server Error](../documentations/screenshots/api-tests/98-server-error.png) |
| **26** | **Server** | Request when backend server is off | `ECONNREFUSED` | N/A | Network Error | ✅ Documented | ![Server Offline](../documentations/screenshots/api-tests/99-server-offline.png) |

## 📅 Last Updated

**Date:** April 9, 2026

**By:** [@neophiles](https://github.com/neophiles)