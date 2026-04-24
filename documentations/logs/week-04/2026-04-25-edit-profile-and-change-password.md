| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-25 |
| **Project** | EUventure |
| **Topic** | Edit Profile and Change Password |
| **Developer** | Tagle |
| **Tags** | `Backend`, `RSCR-Architecture`, `Security`, `Bcrypt`, `Prisma-Schema`, `Zod-Validation` |

# DEV LOG: WEEK 4 - DAY 7

## Core Objective

Empower students with self-service capabilities by implementing secure profile editing and credential management. This update focuses on maintaining data integrity through strict validation while adhering to industry-standard security protocols for password handling.

## 1. Student Profile Management (`PATCH /me`)

We’ve enabled students to keep their academic and personal information up to date without admin intervention.

* **Dynamic Updates:** Implemented `PATCH /me` to allow modification of specific fields: `first_name`, `middle_name`, `last_name`, `program`, `specialization`, and `year_level`.

* **Academic Integrity:** Integrated `EditProfileSchema` using Zod to ensure that shifting programs or updating specializations remains consistent with the university curriculum maps.

* **Tracking Changes:** Added an `updated_at` field to the `Student` model. By using Prisma's `@updatedAt` directive, the system now automatically logs every modification, providing a clear audit trail for profile changes.

## 2. Secure "Verify-then-Update" Password Flow

Security is paramount for EUventure. We’ve moved away from simple updates to a robust multi-step verification process for passwords.

* **Identity Verification:** The new `PATCH /me/password` endpoint enforces a "Knowledge Proof." Before any change occurs, the service uses `bcrypt.compare` to verify the `oldPassword` against the stored hash.

* **One-Way Hashing:** New passwords are never stored in plain text. We utilize `bcrypt` with a salt factor of 10 to hash credentials before they reach the database.

* **Validation Refinement:** The `ChangePasswordSchema` now handles the "Confirm Password" logic at the validation layer, ensuring a match before the request even hits our service logic.

## 3. Standardized Error Handling & API Clean-up

To improve the Developer Experience (DX) for the frontend team, I’ve refined our communication patterns.

* **Semantic Error Codes:** Added specific error details to `error-maps.ts`:
    * `EDIT_PROFILE_FAILED` (400)
    * `INCORRECT_PASSWORD` (401) for password mismatches.
    * `CHANGE_PASSWORD_FAILED` (400)

* **RESTful Routing:** Standardized the profile picture endpoint to `PATCH /me/picture`. This removes the redundant `/upload` suffix, making the API more resource-oriented and intuitive.

* **Optimization:** Performed a refactor of the controller layer to remove unused `multer` dependencies, keeping the backend lightweight.

## 4. Technical Summary & Implementation Details

* **Database:** Executed a Prisma migration to add the `updated_at` column to the `students` table, including a default value to handle existing records.

* **Controllers:** Built `editStudentProfile` and `changeStudentPassword` to handle HTTP requests and responses.

* **Services:** Built `processStudentProfileEdit` and `processStudentPasswordChange` to isolate business logic from the HTTP layer.

* **Repositories:** Updated `students.repository.ts` with dedicated functions for atomic profile and credential updates, ensuring that primary/uniqe identifiers (student number and email) remain immutable.