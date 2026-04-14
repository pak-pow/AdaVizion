import type { Request, Response } from "express";
import * as studentsService from "../services/students.service";
import { LoginSchema, RegistrationSchema } from "../schemas/students.schema";
import { handleControllerError } from "../lib/error-handler";

async function getAllStudents(req: Request, res: Response) {
  try {
    const students = await studentsService.fetchStudents();

    return res.status(200).json(students);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

async function getStudentProfile(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const student = await studentsService.fetchStudent(studentNum);

    const { student_number, ...progress } = await studentsService.fetchStudentProgress(studentNum);

    const studentProfile = {
      ...student,
      progress
    }

    return res.status(200).json(studentProfile);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

async function registerStudent(req: Request, res: Response) {
  try {
    const validation = RegistrationSchema.parse(req.body);
    const studentDetails = validation;

    const newStudent = await studentsService.processStudentRegistration(studentDetails);

    return res.status(201).json(newStudent);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

async function loginStudent(req: Request, res: Response) {
  try {
    const validation = LoginSchema.parse(req.body);
    const studentCredentials = validation;

    const loginDetails = await studentsService.processStudentLogin(studentCredentials);

    return res.status(200).json(loginDetails);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

export {
  getAllStudents,
  getStudentProfile,
  registerStudent,
  loginStudent
}
