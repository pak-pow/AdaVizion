import express from "express";
import { authenticateToken } from "../middleware/auth.middleware";
import * as quizzesController from "../controllers/quizzes.controller";

const router = express.Router();

// User must be logged in to access these routes
router.use(authenticateToken);

// ALL QUIZZES ENDPOINT
router.get("/", quizzesController.getQuizzes); 

// QUIZ DETAILS ENDPOINT
router.get("/:id", quizzesController.getQuiz);

// SUBMIT QUIZ ENDPOINT
router.post("/:id/submit", quizzesController.submitQuiz);

export default router;
