| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-03 |
| **Project** | EUventure |
| **Topic** | JWT Security & Landmark Gamification API |
| **Developer** | Tagle |
| **Tags** | `JWT`, `Security`, `API`, `Gamification`, `Prisma Transactions`, `Dev Log` |

# 📝 DEV LOG: WEEK 2 - DAY 4

**Core Objective:** Secure the API with JWT middleware and implement the core gamified logic for scanning and visiting university landmarks.

1. **The Initiative & Context**

With authentication functioning, the endpoints required an access control mechanism to identify which student is making the request. Following this, the core objective of the app, visiting landmarks to unlock content, needed its API implementation, aligning with our conditional content requirements.

2. **Security & Middleware**

   * **JWT Integration:** Installed `jsonwebtoken` and its types. Updated the `/login` endpoint to issue a token containing the student's number upon successful authentication.

   * **Auth Middleware:** Developed an `authenticateToken` middleware that intercepts requests, verifies the Bearer token against our secret, and injects the decoded payload into the Request object.

   * **Route Protection:** Secured the core routes (`/students`, `/landmarks`) by mounting the middleware in the main application router.

3. **Landmarks & Discovery Logic**

   * **Conditional Content Delivery:**

      * Implemented the `/landmarks/:id` endpoint.

      * Per the SRS requirement (FR-05-04), the endpoint checks if the student has a corresponding `LandmarksVisited` record.

      * If unvisited, the API explicitly strips out the `description` and `fun_fact` from the response and flags `is_unlocked: false`.

   * **The Visit Mechanic (`/landmarks/:id/visit`):**

      * Built the visit endpoint to handle QR scan events.

      * Included logic to reject duplicate check-ins by querying existing visit records.

      * **Atomic Transactions:** Utilized `prisma.$transaction` to simultaneously log the new visit in the `LandmarksVisited` table and increment the student's `total_xp` by a fixed 20 points in the `Progress` table, ensuring data consistency.

4. **Developer Experience**

   * **Live Reloading:** Installed and configured `tsx` in watch mode to automatically restart the server upon code changes, significantly speeding up testing.