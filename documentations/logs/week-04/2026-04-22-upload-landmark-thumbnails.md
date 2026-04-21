| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-22 |
| **Project** | EUventure |
| **Topic** | Automated Landmark Thumbnail Uploads and Asset Syncing |
| **Developer** | Tagle |
| **Tags** | `Supabase`, `Storage`, `Prisma`, `Seeding`, `Refactoring`, `Cloud` |

# DEV LOG: WEEK 4 - DAY 5

## Core Objective

Establish a robust pipeline for managing physical and digital assets (thumbnails and QR codes) by migrating local landmark images to cloud storage (Supabase) and linking live URLs to the database for frontend rendering.

## 1. Automated Asset Pipeline

Developed an integrated workflow to synchronize local image assets with cloud storage.

* **Supabase Storage Integration:** Implemented logic to automatically upload local thumbnail files to the `landmarks/thumbnails` bucket.

* **Asset Refresh & Force Upload:** Temporarily bypassed existing path checks to force a re-upload of all thumbnails, correcting previous unusable image paths.

* **Unified Naming Convention:** Synchronized filenames so that generated QR codes (`.png`) and thumbnails (`.jpg`) share the same base name, simplifying asset tracking per landmark.

## 2. Data Consistency & Persistence

Ensured the JSON manifest and PostgreSQL records stay in sync with cloud assets.

* **URL Manifest Update:** Populated `landmarks.data.json` with actual, working Supabase public URLs. Note: `description` and `fun_fact` fields are currently pending input from Ace Gamitin.

* **In-place Overwrites:** Configured the pipeline to perform in-place overwrites in Supabase. This updates the "Last modified" timestamp without changing the "Added on" date or the public URL, ensuring permanent database links.

## 3. Infrastructure & Refactoring

Standardized helper functions and organized the script architecture for better maintainability.

* **Script Re-organization:** Renamed `generate-qr` to `update-landmarks-data` to better reflect its expanded scope of handling both QR generation and cloud uploads.

* **Shared Utility Helpers:** Introduced a dedicated `createFileBaseName` helper in the library to prevent naming mismatches across different system modules.

* **Import Maintenance:** Updated `seed.ts` to reflect new file structures, keeping the database seeding process functional.

## 4. Developer Experience & Technical Summary

Refined the environment to handle external assets and established storage standards.

* **Git Maintenance:** Added `landmark-thumbnails/` to `.gitignore` to prevent repository bloat. Team members must manually sync this folder from Google Drive into `backend/prisma/data/`.

* **Storage Metadata:** 

   * **Bucket Name:** `landmarks`

   * **Folder Path:** `thumbnails/`

   * **Naming Convention:** `[sanitized-name]-[qr_string].jpg`