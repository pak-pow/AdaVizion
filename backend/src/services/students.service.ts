import bcrypt from "bcrypt";
import * as studentsRepository from "../repositories/students.repository";
import type { LoginBody, RegistrationBody } from "../schemas/students.schema";
import { generateAuthToken } from "./auth.services";

async function fetchStudents() {  
  return await studentsRepository.findStudents();
}

async function fetchStudent(studentNum: string) {
  const student = await studentsRepository.findStudent(studentNum);

  if (!student) throw new Error("Student does not exist");

  return student;
}

async function processStudentRegistration(studentDetails: RegistrationBody) {
  const saltRounds = 10;
  const hashedPassword = await bcrypt.hash(studentDetails.password, saltRounds);

  studentDetails.password = hashedPassword;

  return studentsRepository.createStudent(studentDetails);
}

async function processStudentLogin(studentCredentials: LoginBody) {
  const { studentNum, password } = studentCredentials;

  const student = await studentsRepository.findStudent(studentNum);

  if (!student) {
    throw new Error("Student does not exist");
  }

  const isMatch = await bcrypt.compare(student.password, password);

  if (!isMatch) {
    throw new Error("Invalid student number or password");
  }

  const token = generateAuthToken(studentNum);

  return { student, token };
}

export {
  fetchStudents,
  fetchStudent,
  processStudentRegistration,
  processStudentLogin
}
