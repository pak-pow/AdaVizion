import express from "express";
import { authenticateToken } from "../middleware/auth.middleware";
import * as studentsController from "../controllers/students.controller";

const router = express.Router();

// ALL STUDENTS ENDPOINT
router.get("/", authenticateToken, studentsController.getAllStudents);

// STUDENT PROFILE ENDPOINT
router.get("/me", authenticateToken, studentsController.getStudentProfile);

// REGISTER ENDPOINT
router.post("/register", studentsController.registerStudent);

// LOGIN ENDPOINT
router.post("/login", studentsController.loginStudent);

export default router;
