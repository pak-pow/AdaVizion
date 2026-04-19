import express from "express";
import { authenticateToken } from "../middleware/auth.middleware";
import * as achievementsController from "../controllers/achievements.controller";

const router = express.Router();

// User must be logged in to access these routes
router.use(authenticateToken);

// ACHIEVEMENTS ROOT ENDPOINT
router.get("/", achievementsController.getAchievementslist)

export default router;
