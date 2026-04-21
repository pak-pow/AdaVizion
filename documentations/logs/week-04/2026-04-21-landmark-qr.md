| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-21 |
| **Project** | EUventure |
| **Topic** | JSON Migration & Automated QR Generation |
| **Developer** | Tagle |
| **Tags** | `JSON`, `Prisma`, `QR`, `Seeding`, `Filesystem`, `Refactoring` |

# DEV LOG: WEEK 4 - DAY 4

## Core Objective

Transition landmark data from static TypeScript files to a dynamic, JSON-driven architecture and implement an automated QR code generation pipeline to ensure synchronization between database records and physical assets.

## 1. JSON Data Migration

The data layer was refactored to support language-agnostic access and persistent identifiers.

   * **Transformed Data Formats:** Migrated `landmarks`, `quizzes`, and `achievements` from `.ts` files to `.json` within the `backend/prisma/data/` directory.

   * **Static UUIDs:** Landmarks now include persistent `qr_string` values. This ensures that physical QR codes remain valid and linked to the correct database record even if the database is reset.

## 2. Automated QR Code Generation (`backend/prisma/generate-qr.ts`)

Developed a dedicated script to automate the creation of physical exploration triggers.

   * **Dynamic Generation:** Added a script that scans the landmark JSON, generates unique UUIDs for new entries, and creates high-correction-level (`H`) QR code images.

   * **Filesystem Sync:** The script automatically manages the `qr-codes/` directory, ensuring images match the current JSON state.

   * **Indented JSON Output:** Implemented formatted JSON writing (`null, 2`) to maintain human-readability of data files after script-driven updates.

## 3. New Filesystem Utilities (`backend/src/lib/fs-utils.ts`)

Standardized how the application handles path resolution and data persistence in an ESM environment.

   * **Path Helpers** Introduced `getFileName` and `getDirectoryName` to handle ESM `import.meta.url` path resolution.

   * **JSON I/O:** Added centralized `readJSON` and `writeJSON` helpers to standardize application interaction with data files.

## 4. Enhanced Seeding Logic (`backend/prisma/seed.ts`)

Integrated the asset generation and database population workflows.

   * **Integrated Workflow:** The seeding process now triggers the `updateLandmarksData` script first to ensure all QR strings exist before database insertion.

   * **Prisma Upserts:** Ensure all seeding functions remain to use `upsert` logic, preventing duplicate key errors and allowing for rapid data adjustments without clearing the database.

## 5. Developer Experience & Chore

Refined the development environment to handle generated binary assets efficiently.

   * **Dependency Addition:** Installed `qrcode` for high-fidelity image generation.

   * **Git Maintenance:** Added `backend/prisma/data/qr-codes/` to `.gitignore` to prevent repository bloat while keeping the generation logic accessible for local development.