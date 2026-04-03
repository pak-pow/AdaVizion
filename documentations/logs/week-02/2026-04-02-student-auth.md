| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-02 |
| **Project** | EUventure |
| **Topic** | Core API Initialization & Student Authentication Layer |
| **Developer** | Tagle |
| **Tags** | `Express.js`, `API`, `Authentication`, `Zod`, `Bcrypt`, `Dev Log` |

# 📝 DEV LOG: WEEK 2 - DAY 3

**Core Objective:** Initialize the Express.js server and build a secure, validated authentication layer (registration and login) for students.

1. **The Initiative & Context**

Now that the database is active, the frontend requires secure endpoints to manage user sessions. Manual input validation is prone to errors and difficult to scale, so I opted for a schema-driven architecture using Zod. Additionally, raw passwords can never be stored, requiring integration with Bcrypt.

2. **API Validation Layer (Zod)**

   * **Schema Definition:** Created a `RegistrationSchema` and `LoginSchema` to enforce type-safe request parsing.

   * **Institutional Constraints:** Configured the registration validation to strictly require email addresses ending in `@student.mseuf.edu.ph`.

   * **Formatting Rules:** Added string limits, such as a 20-character maximum for student numbers and an 8-character minimum for passwords.

   * **Data Transformation:** Set the `middleName` attribute to automatically transform empty strings into `null` to satisfy PostgreSQL database constraints.

3. **Authentication Engine & Endpoints**

   * **Server Setup:** Installed Express and initialized the base server architecture.

   * **Registration (`/register`):**

      * Implemented password hashing using `bcrypt` with 10 salt rounds.

      * Utilized Prisma transactions (`prisma.$transaction`) to guarantee that the creation of a `Student` record and their associated `Progress` record happen atomically.

      * Destructured the generated password out of the return object to ensure sensitive data is never passed back to the client.

   * **Login (`/login`):**

      * Added endpoint logic to fetch the student and compare the provided password against the stored hash using `bcrypt.compare()`.

   * **Landmark Model Update:** Added the `qr_string` attribute to the `Landmark model`, a prerequisite for verifying physical QR codes later on.