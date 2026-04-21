import bcrypt from "bcrypt";
import * as studentsRepository from "../repositories/students.repository";
import * as landmarksRepository from "../repositories/landmarks.repository";
import type { LoginBody, RegistrationBody } from "../schemas/students.schema";
import { generateAuthToken } from "./auth.services";
import { calculateXpProgress } from "../lib/gamification-utils";

async function fetchStudents() {  
  const students = await studentsRepository.findStudents();

  // Exclude password from response
  return students.map(({ password, ...publicData }) => {
    const { progress, ...info } = publicData;

    return {
      info,
      progress
    }
  });
}

async function fetchStudent(studentNum: string) {
  const student = await studentsRepository.findStudent(studentNum);

  // Exclude password from response
  if (!student) throw new Error("Student does not exist");

  const { password, ...publicData } = student;

  return publicData;
}

async function fetchStudentProfile(studentNum: string) {
  const [
    student,
    progress,
    landmarksVisitedCount,
    totalLandmarks
  ] = await Promise.all([
    studentsRepository.findStudent(studentNum),
    studentsRepository.findStudentProgress(studentNum),
    landmarksRepository.findLandmarksVisitedCount(studentNum),
    landmarksRepository.findLandmarksCount()
  ]);

  if (!progress) throw new Error("Student progress does not exist");

  const { student_number, total_xp, ...otherProgress } = progress;

  const xpProgress = calculateXpProgress(progress.level, total_xp);

  return {
    info: student,
    progress: {
      ...otherProgress,
      landmarks: {
        total: totalLandmarks,
        visited: landmarksVisitedCount
      },
      xp: {
        total_xp: total_xp,
        ...xpProgress
      }    
    }
  };
}

async function processStudentRegistration(studentDetails: RegistrationBody) {
  const saltRounds = 10;
  const hashedPassword = await bcrypt.hash(studentDetails.password, saltRounds);

  studentDetails.password = hashedPassword;

  const newStudent = await studentsRepository.createStudent(studentDetails);

  // Exclude password from response
  const { password, ...publicData } = newStudent;

  return {
    message: "Sign-up successful",
    student: publicData
  };
}

async function processStudentLogin(studentCredentials: LoginBody) {
  const { studentNum, password } = studentCredentials;

  const student = await studentsRepository.findStudent(studentNum);

  const isMatch = student ? await bcrypt.compare(password, student.password) : false;

  if (!student || !isMatch) {
    throw new Error("Incorrect student number or password");
  }

  const token = generateAuthToken(studentNum);

  // Exclude password from response
  const { password: privatePass, ...publicData } = student;

  return {
    message: "Login successful",
    token: token,
    student: publicData
  };
}

async function processStudentPicture(studentNum: string, pictureFile: Express.Multer.File) {
  const fileExtension = pictureFile.originalname.split(".").at(-1);
  const fileName = `${studentNum}/${studentNum}-${Date.now()}.${fileExtension}`;

  const updatedStudent = await studentsRepository.updateStudentPicture(
    studentNum,
    fileName,
    pictureFile.buffer,
    pictureFile.mimetype
  );

  if (!updatedStudent) {
    throw new Error("Failed to link uploaded image to student profile");
  }

  const { student_number, img_path } = updatedStudent;

  return {
    message: "Profile picture uploaded successfully",
    student_number,
    img_path 
  }
}

export {
  fetchStudents,
  fetchStudent,
  fetchStudentProfile,
  processStudentRegistration,
  processStudentLogin,
  processStudentPicture
}
