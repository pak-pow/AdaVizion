| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-24 |
| **Project** | EUventure |
| **Topic** | Gamification Infrastructure, Asset Pipelines, and Seeding Stability |
| **Developer** | Tagle |
| **Tags** | `Prisma`, `PostgreSQL`, `Supabase`, `Gamification`, `DevOps`, `Data-Integrity` |

# DEV LOG: WEEK 4 - DAY 6

## Core Objective

Strengthen the project's gamification layer by implementing a tiered achievement system with automated SVG asset management, while resolving critical database seeding bottlenecks to ensure a stable development environment.

## 1. Gamification & Asset Pipeline

Established a scalable architecture for achievement badges to improve both developer workflow and user experience.

* **Tiered Achievement System:** Introduced a `tier` attribute (Level 1, 2, 3) to the `Achievement` model. This allows for semantic categorization (e.g., Bronze, Silver, Gold) and simplifies frontend rendering logic.

* **SVG Badge Pipeline:** Implemented `update-achievements-data.ts` to automate the uploading of badge assets to Supabase Storage. This script programmatically updates `achievements.data.json` with live public URLs.

* **Storage Optimization:** Configured the system to use SVG format for badges, ensuring infinite scalability and minimal storage footprints, helping the project stay within Supabase free-tier limits.

## 2. Database Stability & Seeding Logic

Refactored the seeding process to handle real-world data scenarios, specifically regarding existing student progress.

* **P2003 Constraint Resolution:** Identified and resolved a Foreign Key Constraint violation in the `seedQuizzes` function. Replaced the "destructive" `deleteMany` approach with a granular `upsert` strategy.

* **Subsequent Seeding Support:** The new logic allows the team to run `npm run seed` without wiping out existing `QuestionSubmissions`, preserving user test data during development.

* **Unique Constraints:** Added a `@unique` constraint to the `question_text` in the `Question` model to enable precise record targeting during the upsert process.

## 3. Data Completion & Schema Refinement

Finalized core content for campus landmarks and standardized data types across the schema.

* **Landmark Metadata Delivery:** Fully populated the landmark JSON manifest with official descriptions and fun facts for all 9 university locations.

* **Schema Hardening:** Applied `@db.VarChar(255)` to the `qr_string` in the `Landmark` model to ensure stricter data typing and prevent potential overflow issues.

* **Clean Repository Standards:** Updated `.gitignore` to exclude `achievement-badges/`, maintaining a lean repository while relying on cloud-hosted assets for the production environment.

## 4. Developer Experience & Technical Summary

* **Prisma Updates:** Required a schema migration to support new unique constraints and the Achievement tiering.

* **Seeding Efficiency:** The `seed.ts` file runs sequentially (`Landmarks` -> `Quizzes` -> `Achievements`) to prevent race conditions during the initial database setup.

* **Asset Syncing:** Developers can now sync badges to the cloud simply by placing SVGs in the data folder and running the updated seed script.