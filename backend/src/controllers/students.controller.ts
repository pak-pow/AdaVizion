import type { Request, Response } from "express";
import * as studentsService from "../services/students.service";
import { LoginSchema, RegistrationSchema } from "../schemas/students.schema";
import { STUDENT_ERRORS } from "../constants/error-maps";
import { handleControllerError } from "../lib/error-handler";

async function getAllStudents(req: Request, res: Response) {
  try {
    const students = await studentsService.fetchStudents();

    return res.status(200).json(students);
  } catch (error: any) {
    return handleControllerError(res, error, STUDENT_ERRORS);
  }
}

async function getStudentProfile(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const studentProfile = await studentsService.fetchStudent(studentNum);

    return res.status(200).json(studentProfile);
  } catch (error: any) {
    return handleControllerError(res, error, STUDENT_ERRORS);
  }
}

async function registerStudent(req: Request, res: Response) {
  try {
    const validation = RegistrationSchema.safeParse(req.body);
    
    if (!validation.success) {
      return res.status(400).json({
        error: validation.error?.issues[0]?.message
      });
    }

    const studentDetails = validation.data;

    const newStudent = await studentsService.processStudentRegistration(studentDetails);

    // Remove password from response
    const { password, ...publicData } = newStudent;

    return res.status(201).json(publicData);
  } catch (error: any) {
    return handleControllerError(res, error, STUDENT_ERRORS);
  }
}

async function loginStudent(req: Request, res: Response) {
  try {
    const validation = LoginSchema.safeParse(req.body);

    if (!validation.success) {
      return res.status(400).json({
        error: validation.error?.issues[0]?.message
      });
    }

    const studentCredentials = validation.data;

    const { student, token } = await studentsService.processStudentLogin(studentCredentials);

    // Remove password from response
    const { password, ...publicData } = student;

    return res.status(200).json({
      message: "Login successful",
      token: token,
      student: publicData
    });
  } catch (error: any) {
    return handleControllerError(res, error, STUDENT_ERRORS);
  }
}

export {
  getAllStudents,
  getStudentProfile,
  registerStudent,
  loginStudent
}
