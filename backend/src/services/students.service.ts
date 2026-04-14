import bcrypt from "bcrypt";
import * as studentsRepository from "../repositories/students.repository";
import * as landmarksRepository from "../repositories/landmarks.repository";
import type { LoginBody, RegistrationBody } from "../schemas/students.schema";
import { generateAuthToken } from "./auth.services";
import { calculateXpProgress } from "../lib/gamification-utils";

async function fetchStudents() {  
  return await studentsRepository.findStudents();
}

async function fetchStudent(studentNum: string) {
  const student = await studentsRepository.findStudent(studentNum);

  if (!student) throw new Error("Student does not exist");

  const { password, ...publicData } = student;

  return publicData;
}

async function fetchStudentProgress(studentNum: string) {
  const progress = await studentsRepository.findStudentProgress(studentNum);
  const landmarksVisitedCount = await landmarksRepository.findLandmarksVisitedCount(studentNum);
  const totalLandmarks = await landmarksRepository.findLandmarksCount();

  if (!progress) throw new Error("Student progress does not exist");

  const { total_xp, ...otherProgress } = progress;

  const xpProgress = calculateXpProgress(progress.level, total_xp);

  return {
    ...otherProgress,
    landmarks: {
      total: totalLandmarks,
      visited: landmarksVisitedCount
    },
    xp: {
      total_xp: total_xp,
      ...xpProgress
    }    
  };
}

async function processStudentRegistration(studentDetails: RegistrationBody) {
  const saltRounds = 10;
  const hashedPassword = await bcrypt.hash(studentDetails.password, saltRounds);

  studentDetails.password = hashedPassword;

  const newStudent = await studentsRepository.createStudent(studentDetails);

  // Remove password from response
  const { password, ...publicData } = newStudent;

  return publicData;
}

async function processStudentLogin(studentCredentials: LoginBody) {
  const { studentNum, password } = studentCredentials;

  const student = await studentsRepository.findStudent(studentNum);

  const isMatch = student ? await bcrypt.compare(password, student.password) : false;

  if (!student || !isMatch) {
    throw new Error("Incorrect student number or password");
  }

  const token = generateAuthToken(studentNum);

  // Remove password from response
  const { password: privatePass, ...publicData } = student;

  return {
    message: "Login successful",
    token: token,
    student: publicData
  };
}

export {
  fetchStudents,
  fetchStudent,
  fetchStudentProgress,
  processStudentRegistration,
  processStudentLogin
}
