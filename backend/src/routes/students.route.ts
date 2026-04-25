import express from "express";
import multer from "multer";
import { authenticateToken } from "../middleware/auth.middleware";
import * as studentsController from "../controllers/students.controller";

const router = express.Router();

const storage = multer.memoryStorage();

const fileSizeLimit = 50 * 1000000; // Limited by Supabase free tier (50 MB)

const upload = multer({
  storage: storage,
  limits: { fileSize: fileSizeLimit },
  fileFilter: (req, file, callback) => { 
    if (file.mimetype.startsWith("image/")) {
      callback(null, true);
    } else {
      callback(new Error("Only image files are allowed"));
    }
  }
});

// ALL STUDENTS ENDPOINT
router.get("/", authenticateToken, studentsController.getAllStudents);

// STUDENT PROFILE ENDPOINT
router.get("/me", authenticateToken, studentsController.getStudentProfile);

// REGISTER ENDPOINT
router.post("/register", studentsController.registerStudent);

// LOGIN ENDPOINT
router.post("/login", studentsController.loginStudent);

// EDIT PROFILE ENDPOINT
router.patch("/me", authenticateToken, studentsController.editStudentProfile);

// CHANGE PASSWORD ENDPOINT
router.patch("/me/password", authenticateToken, studentsController.changeStudentPassword);

// UPLOAD PROFILE PICTURE ENDPOINT
router.patch(
  "/me/picture",
  authenticateToken,
  upload.single("picture-file"),
  studentsController.uploadProfilePicture
);

export default router;
