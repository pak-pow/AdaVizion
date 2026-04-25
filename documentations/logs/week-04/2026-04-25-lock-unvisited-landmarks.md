| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-25 |
| **Project** | EUventure |
| **Topic** | Landmark Discovery Mechanics and Content Access Control |
| **Developer** | Tagle |
| **Tags** | `Backend`, `Services`, `Logic-Refactoring`, `UX-Security`, `Error-Handling` |

# DEV LOG: WEEK 4 - DAY 7

## Core Objective

Transition the landmark exploration from a static directory to a dynamic discovery-first experience. This update ensures that the educational value of the landmarks (descriptions and fun facts) remains hidden until physically unlocked, encouraging actual campus traversal.

## 1. Discovery-Based Content Masking

To maintain the scavenger hunt feel of EUventure, we have tightened the data visibility in the landmark checklist.

* **Total Content Lockdown:** Refactored `fetchLandmarkChecklist` in the service layer. Previously, only the fun facts were hidden; now, the `description` is also excluded for unvisited landmarks.

* **Encouraging Exploration:** Students can now only see the landmark's name and basic metadata. All rich educational content is stripped from the API response unless the `is_visited` flag is true, preventing spoiling the landmark's history before the student arrives.

## 2. Secure Access Control

We implemented a server-side gatekeeper to prevent unauthorized access to landmark data via direct URL manipulation or deep links.

* **Restricted Direct Access:** Refactored `fetchLandmark` to validate a student's visit history. If a student tries to access a landmark's details (`/landmarks/:id`) without having scanned its unique QR code first, the system will now explicitly block the request.

* **Backend Validation:** This ensures that discovery cannot be bypassed by simply guessing landmark IDs, keeping the gamification loop secure and meaningful.

## 3. Error Handling & UI Feedback

Standardized the communication between the backend and frontend for locked content.

* **New `LANDMARK_LOCKED` Error:** Added a specific error definition to `error-maps.ts`.

* **HTTP 423 Status Code:** Used the `423 Locked` status code to indicate that the resource is inaccessible due to a missing prerequisite (the scan).

* **Semantic Messaging:** The error returns a clear "Scan landmark QR first" message. This allows the mobile frontend to gracefully handle the rejection and display a specific "Locked" UI state or a hint to the user.