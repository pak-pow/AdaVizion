| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-22 |
| **Project** | EUventure |
| **Topic** | Storage Optimization & Profile Picture Cleanup |
| **Developer** | Tagle |
| **Tags** | `Supabase`, `Prisma`, `Storage`, `Cleanup`, `Refactoring` |

# DEV LOG: WEEK 4 - DAY 5

## Core Objective

Implement an automated cleanup mechanism for student profile pictures to optimize storage usage on the Supabase free tier (1GB limit) by preventing the accumulation of orphaned files.

## 1. Repository Layer Logic (`students.repository.ts`)

Refactored the student media persistence layer to support atomic-style updates with post-transaction cleanup.

* **Interface Modification:** Updated `updateStudentPicture` to accept an `oldFilePath` parameter.

* **Post-Link Deletion:** Implemented logic to trigger the deletion of the previous avatar **only** after the new image URL has been successfully linked to the PostgreSQL record.

* **Resilient Cleanup:** Configured the `remove()` operation as a "soft failure" with dedicated logging to ensure that minor storage API issues do not interrupt the primary user upload flow.

## 2. Service Layer Logic (`students.service.ts`)

Enhanced the profile picture processing service to handle path resolution and state management.

* **State Verification:** Integrated `studentsRepository.findStudent()` to retrieve current profile metadata, specifically checking for existing `img_path` values.

* **Dynamic Path Resolution:** Implemented logic to extract the filename from the existing public URL and reconstruct the storage path for the legacy file.

* **Asset Organization:** Maintained the directory structure where each student has a dedicated folder (named by `student_number`), containing the profile picture file named `[student_number]-[timestamp].[extension]`.

## 3. Storage Optimization & Integrity

Prioritized storage efficiency without compromising user data reliability.

* **O(1) Storage Footprint:** Transitioned from an indefinite file growth model to a constant storage footprint per student (1 file per active user).

* **Atomic-First Execution:** Structured the code so the old file is deleted last, ensuring that if a process crashes mid-way, the student's profile never points to a non-existent "dead" link.

## 4. Technical Summary (Supabase)

* **Bucket Name:** `student-avatars`
* **Folder Path:** `[student_number]/`
* **File Convention:** `[student_number]-[Date.now()].[extension]`