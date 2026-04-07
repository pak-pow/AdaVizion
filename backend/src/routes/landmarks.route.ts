import express from "express";
import { authenticateToken } from "../middleware/auth.middleware";
import * as landmarksController from "../controllers/landmarks.controller";

const router = express.Router();

// User must be logged in to access these routes
router.use(authenticateToken);

// LANDMARKS ROOT ENDPOINT
router.get("/", landmarksController.getLandmarkChecklist);

// LANDMARK DETAILS ENDPOINT
router.get("/:id", landmarksController.getLandmark);

// VISIT LANDMARK ENDPOINT
router.post("/:id/visit", landmarksController.visitLandmark);

export default router;
