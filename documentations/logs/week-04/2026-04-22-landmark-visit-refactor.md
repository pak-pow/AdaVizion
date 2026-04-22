| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-22 |
| **Project** | EUventure |
| **Topic** | Landmark Visit Refactor & QR-Based Lookup |
| **Developer** | Tagle |
| **Tags** | `Landmarks`, `Refactoring`, `API-Optimization` |

# DEV LOG: WEEK 4 - DAY 5

## Core Objective

Refactor the landmark "visit" workflow to shift lookup logic from the frontend to the backend. The goal is to eliminate the need for the mobile app to fetch the entire landmark checklist just to map a scanned QR string to a landmark ID, thereby optimizing network performance and user experience.

## 1. API & Route Optimization

Streamlined the endpoint structure to simplify the request lifecycle for frontend developers.

* **Route Flattening:** Renamed and simplified the endpoint from `/landmarks/:id/visit` to a direct `/landmarks/visit` POST route.

* **Payload Simplification:** Transitioned from URL path parameters to a clean request body. The frontend now only needs to send the raw `qr_code_scanned` string.

* **Network Efficiency:** Reduced the required sequence for a scan from two network requests (fetch-all + post-visit) to a single, atomic transaction.

## 2. Service & Repository Enhancement

Updated the business logic and data access layers to handle internal landmark resolution.

* **QR-Based Lookup:** Introduced `findLandmarkByQr` in the `landmarks.repository.ts` to allow direct record retrieval using the persistent UUID string.

* **Service Decoupling:** Refactored `processLandmarkVisit` in the service layer to remove the `landmarkId` dependency. The service now independently resolves the landmark record, validates the scan, and triggers gamification logic (XP and Level-ups).

* **Validation Logic:** Maintained strict backend validation to ensure the scanned string matches the database record, preventing spoofed visits while allowing for a more flexible frontend implementation.

## 3. Technical Summary of Changes

### API Specification
* **Old Endpoint:** `POST /landmarks/:id/visit`
* **New Endpoint:** `POST /landmarks/visit`
* **Payload:** `{ "qr_code_scanned": "string" }`

### Modified Files
* **Repository:** `backend/src/repositories/landmarks.repository.ts` (Added `findLandmarkByQr`)
* **Service:** `backend/src/services/landmarks.service.ts` (Refactored `processLandmarkVisit`)
* **Controller:** `backend/src/controllers/landmarks.controller.ts` (Updated `visitLandmark`)
* **Routes:** `backend/src/routes/landmarks.route.ts` (Updated visit route)