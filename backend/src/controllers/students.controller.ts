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

    const studentProfile = await studentsService.fetchStudent(studentNum);

    return res.status(200).json(studentProfile);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
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

    return res.status(201).json(newStudent);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
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

    const loginDetails = await studentsService.processStudentLogin(studentCredentials);;

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
