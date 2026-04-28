# EUventure Backend Documentation

Welcome to the backend documentation for EUventure! The APIs power the interactive gamification, student tracking, QR scanning, and quiz submission features of the platform.

## 🏗️ Architecture

The backend has been completely overhauled to follow a strictly typed **Route-Controller-Service-Repository (RCSR)** architecture. This ensures a clean separation of concerns:

| Layer | Description |
| :--- | :--- |
| **Routes** | Defines endpoints and mounts the middlewares. |
| **Controllers** | Handles request validation using Zod and coordinates HTTP responses. |
| **Services** | Contains pure business logic, such as XP calculations, evaluating quiz correctness, and processing reusable `checkAchievements` triggers. |
| **Repositories** | Manages the direct data access layer via Prisma and Supabase API. |

## ✨ Core Features & Technical Decisions

### 1. Security & Authentication

- **JWT & Passwords:** Uses `jsonwebtoken` for secure student sessions and `bcrypt` (10 salt rounds) for password hashing. Passwords are destructured and never returned in JSON payloads.

- **Validation Layer:** Implements schema-driven validation using **Zod** for type-safe request parsing, eliminating manual `if` checks.

- **MSEUF Restriction:** Registration enforces the `@student.mseuf.edu.ph` domain and validates data against real-world academic programs (`academic-maps.ts`).

### 2. Gamification & Data Integrity

- **Atomic Transactions:** Uses `prisma.$transaction` to ensure actions like recording a landmark visit and rewarding XP happen simultaneously and atomically.

- **Progressive Discovery:** Unvisited landmarks hide their `fun_fact` and `description` from the student until successfully scanned.

- **Granular Tracking:** Quizzes track individual `is_correct` answers, `passing_score`, and `max_score` for detailed student feedback.

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
| `GET` | `/` | Server welcome message. |
| `GET` | `/health` | Checks the health of the backend server (Prisma & Supabase connectivity). |
| `GET` | `/students` | Fetches a list of all registered students. Requires authentication. |
| `POST` | `/students/register` | Registers a new student, hashes their password, enforces MSEUF email constraints, and automatically initializes their `Progress` record. |
| `POST` | `/students/login` | Authenticates a student via password comparison and returns a JWT session token. |
| `GET` | `/students/me` | Fetches the currently authenticated student's profile, including their XP progress and earned achievements. |
| `PATCH` | `/students/me` | Updates the student's academic profile (program, specialization). Requires authentication. |
| `PATCH` | `/students/me/password` | Changes the student's password after validating the old password. Requires authentication. |
| `PATCH` | `/students/me/picture` | Uploads and stores the student's profile picture to Supabase. Requires authentication. |
| `GET` | `/landmarks` | Fetches the landmark checklist. Visibility of facts/descriptions is conditionally hidden if `is_visited: false`. |
| `GET` | `/landmarks/:id` | Fetches details for a specific landmark. Secures `qr_string` and `fun_fact` from unvisited users. |
| `POST` | `/landmarks/visit` | Verifies a QR scan via `qr_code_scanned` in request body, checks for duplicate visits, saves the visit, and automatically updates the student's XP. |
| `GET` | `/quizzes` | Returns a list of all quizzes, including lock status, remaining landmark visits needed to unlock, and completion history. |
| `GET` | `/quizzes/:id` | Fetches a specific quiz and its question list. Includes the student's previous score if the quiz is already completed. |
| `POST` | `/quizzes/:id/submit` | Evaluates quiz answers for correctness, calculates the score, updates XP, and checks for newly unlocked achievements |
| `GET` | `/achievements` | Returns all available achievement badges in the system, utilizing the `is_unlocked` flag to dynamically display which ones the authenticated student has earned. |

## 🗄️ Database Schema Summary

The PostgreSQL database is managed via Prisma and includes the following primary models:
- `Student`, `Progress`
- `Landmark`, `LandmarksVisited`
- `Quiz`, `Question`, `QuizSubmission`
- `Achievement`, `AchievementsEarned`

> Note: All models include audit trails like `created_at` and `updated_at`.

## 🚀 Development Setup

To run the backend locally, ensure you have your .env configured and your database seeded.

### 1. Install dependencies

```Bash
cd backend
npm install
```

### 2. Configure environment

Duplicate `.env.example` as `.env` and populate it with the following variables:

```env
DATABASE_URL=""
SUPABASE_URL=""
SUPABASE_SERVICE_ROLE_KEY=""
PORT=3000
JWT_SECRET=""
FRONTEND_ORIGIN="http://localhost:5000"
```

>**Note:** Please reach out to [@neophiles](https://github.com/neophiles) to get the actual environment values. For the `JWT_SECRET`, you can ask for the team's shared key or generate your own random string for local testing.

### 3. Generate Prisma client and sync schema

```Bash
npx prisma generate
npx prisma migrate dev
```

### 4. **(OPTIONAL)** Seed initial Landmarks, Quizzes, and Achievements

As of **April 28, 2026**, the database is already seeded with the data. Please proceed to the next step.

```Bash
npm run seed
```

### 5. Run the server with `tsx watch` mode for fast auto-restarts

```Bash
npm run dev
```

## API Test Matrix

To ensure the reliability of the **EUventure** API and the security of student data, the core responses and business logic were rigorously tested using **Postman** and **Thunder Client**. These tests verify that our centralized error handling correctly maps domain-specific failures to a standardized JSON contract for the Flutter frontend.

### 1. Home & Health

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **HOME-01** | Fetch server welcome message | `200 OK` | N/A | Welcome message returned | ✅ | ![HOME-01](../documentations/screenshots/api-tests-2/HOME/HOME-01.png) |
| **HEALTH-01** | Check server health status | `200 OK` | N/A | Prisma & Supabase are connected and operational | ✅ | ![HEALTH-01](../documentations/screenshots/api-tests-2/HOME/HEALTH-01.png) |

### 2. Security

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SEC-01** | Access protected route without token | `401 Unauthorized` | `MISSING_TOKEN` | "Access denied due to missing token" | ✅ | ![SEC-01](../documentations/screenshots/api-tests-2/SEC/SEC-01.png) |
| **SEC-02** | Access with tampered or expired JWT | `401 Unauthorized` | `INVALID_TOKEN` | "Invalid or expired token" | ✅ | ![SEC-02](../documentations/screenshots/api-tests-2/SEC/SEC-02.png) |

### 3. Authentication

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **AUTH-01** | Register with valid student data | `201 Created` | N/A | User saved | ✅ | ![AUTH-01](../documentations/screenshots/api-tests-2/AUTH/AUTH-01.png) |
| **AUTH-02** | Register already existing student | `409 Conflict` | DUPLICATE_STUDENT | "Student number or email already exists" | ✅ | ![AUTH-02](../documentations/screenshots/api-tests-2/AUTH/AUTH-02.png) |
| **AUTH-03** | Register with mismatching MSEUF email | `400 Bad Request` | VALIDATION_ERROR | "Email must match your student number" | ✅ | ![AUTH-03](../documentations/screenshots/api-tests-2/AUTH/AUTH-03.png) |
| **AUTH-04** | Register with non-existent Program | `400 Bad Request` | VALIDATION_ERROR | "Please select a valid MSEUF academic program | ✅ | ![AUTH-04](../documentations/screenshots/api-tests-2/AUTH/AUTH-04.png) |
| **AUTH-05** | Register with invalid Specialization | `400 Bad Request` | VALIDATION_ERROR | "Invalid specialization for the selected program" | ✅ | ![AUTH-05](../documentations/screenshots/api-tests-2/AUTH/AUTH-05.png) |
| **AUTH-06** | Login with correct credentials | `200 OK` | N/A | JWT returned | ✅ | ![AUTH-06](../documentations/screenshots/api-tests-2/AUTH/AUTH-06.png) |
| **AUTH-07** | Login with wrong student number or password | `401 Unauthorized` | INCORRECT_CREDENTIALS | "Incorrect student number or password" | ✅ | ![AUTH-07](../documentations/screenshots/api-tests-2/AUTH/AUTH-07.png) |

### 4. Profile

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PROF-01** | Fetch authenticated student profile | `200 OK` | N/A | Student profile data with academic info and progress | ✅ | ![PROF-01](../documentations/screenshots/api-tests-2/PROF/PROF-01.png) |
| **PROF-02** | Edit student academic profile | `200 OK` | N/A | Updated profile data | ✅ | ![PROF-02](../documentations/screenshots/api-tests-2/PROF/PROF-02.png) |
| **PROF-03** | Upload profile picture | `200 OK` | N/A | Picture uploaded to Supabase and URL returned | ✅ | ![PROF-03](../documentations/screenshots/api-tests-2/PROF/PROF-03.png) |
| **PROF-04** | Change password successfully | `200 OK` | N/A | Password changed successfully | ✅ | ![PROF-04](../documentations/screenshots/api-tests-2/PROF/PROF-04.png) |
| **PROF-05** | Change password with incorrect old password | `401 Unauthorized` | `INCORRECT_PASSWORD` | "Incorrect password" | ✅ | ![PROF-05](../documentations/screenshots/api-tests-2/PROF/PROF-05.png) |
| **PROF-06** | Change password with mismatched new passwords | `400 Bad Request` | `VALIDATION_ERROR` | "Passwords do not match" | ✅ | ![PROF-06](../documentations/screenshots/api-tests-2/PROF/PROF-06.png) |

### 5. Landmarks

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **LAND-01** | Fetch all landmarks (New Student) | `200 OK` | N/A | List with `is_visited: false` and hidden description and facts | ✅ | ![LAND-01](../documentations/screenshots/api-tests-2/LAND/LAND-01.png) |
| **LAND-02** | Fetch details for unvisited landmark | `423 LOCKED` | N/A | "Scan landmark QR first" | ✅ | ![LAND-02](../documentations/screenshots/api-tests-2/LAND/LAND-02.png) |
| **LAND-03** | Scan QR / Visit landmark (First Time) | `200 OK` | N/A | Visit saved, XP awarded, and achievement unlocked | ✅ | ![LAND-03](../documentations/screenshots/api-tests-2/LAND/LAND-03.png) |
| **LAND-04** | Fetch details for visited landmark | `200 OK` | N/A | `description` and `fun_fact` revealed | ✅ | ![LAND-04](../documentations/screenshots/api-tests-2/LAND/LAND-04.png) |
| **LAND-05** | Fetch a landmark ID that doesn't exist | `404 Not Found` | `LANDMARK_NOT_FOUND` | "Landmark not found" | ✅ | ![LAND-05](../documentations/screenshots/api-tests-2/LAND/LAND-05.png) |
| **LAND-06** | Attempt to scan same QR again | `400 Bad Request` | `DUPLICATE_LANDMARK` | "Landmark already visited" | ✅ | ![LAND-06](../documentations/screenshots/api-tests-2/LAND/LAND-06.png) |

### 6. Quizzes

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **QUIZ-01** | Fetch all quizzes | `200 OK` | N/A | List of quizzes with locked/unlocked status and XP requirements | ✅ | ![QUIZ-01](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-01.png) |
| **QUIZ-02** | Fetch an unlocked quiz | `200 OK` | N/A | Quiz details with questions and options | ✅ | ![QUIZ-02](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-02.png) |
| **QUIZ-03** | Fetch a locked quiz | `403 Forbidden` | `QUIZ_LOCKED` | "Quiz requires more landmark visits to unlock" | ✅ | ![QUIZ-03](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-03.png) |
| **QUIZ-04** | Submit valid quiz answers | `200 OK` | N/A | Score calculated, XP awarded, and submission saved | ✅ | ![QUIZ-04](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-04.png) |
| **QUIZ-05** | Fetch a previously completed quiz | `200 OK` | N/A | Quiz with `total_score` and questions with `is_correct` flags | ✅ | ![QUIZ-05](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-05.png) |
| **QUIZ-06** | Fetch a quiz ID that doesn't exist | `404 Not Found` | `QUIZ_NOT_FOUND` | "Quiz not found" | ✅ | ![QUIZ-06](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-06.png) |
| **QUIZ-07** | Attempt to resubmit an already completed quiz | `409 Conflict` | `DUPLICATE_QUIZ` | "Quiz already answered" | ✅ | ![QUIZ-07](../documentations/screenshots/api-tests-2/QUIZ/QUIZ-07.png) |

### 7. Achievements

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **ACH-01** | Fetch all student achievements | `200 OK` | N/A | List of all achievements with `is_unlocked` flags | ✅ | ![ACH-01](../documentations/screenshots/api-tests-2/ACH/ACH-01.png) |

### 8. Server

| Case ID | Scenario | Status Code | Error Code | Expected Result | Status | Screenshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SER-01** | Server-side crash and other errors | `500 Internal Server Error` | `INTERNAL_SERVER_ERROR` | "Internal Server Error" | ✅ | ![SER-01](../documentations/screenshots/api-tests-2/SER/SER-01.png) |
| **SER-02** | Request when backend server is off | `ECONNREFUSED` | N/A | Network Error | ✅ | ![SER-02](../documentations/screenshots/api-tests-2/SER/SER-02.png) |

## 📅 Last Updated

**Date:** April 28, 2026

**By:** [@neophiles](https://github.com/neophiles)