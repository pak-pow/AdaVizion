import type { Request, Response } from "express";
import multer from "multer";
import * as studentsService from "../services/students.service";
import { ChangePasswordSchema, EditProfileSchema, LoginSchema, RegistrationSchema } from "../schemas/students.schema";
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

    const profile = await studentsService.fetchStudentProfile(studentNum);

    return res.status(200).json(profile);
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

async function uploadProfilePicture(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const pictureFile = req.file;

    if (!pictureFile) {
      throw new Error("No file uploaded");
    }

    const uploadResult = await studentsService.processStudentPicture(studentNum, pictureFile);

    return res.status(200).json(uploadResult);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

async function editStudentProfile(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const validation = EditProfileSchema.parse(req.body);
    const updatedProfileData = validation;

    const editResult = await studentsService.processStudentProfileEdit(
      studentNum,
      updatedProfileData
    );

    return res.status(200).json(editResult);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

async function changeStudentPassword(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const validation = ChangePasswordSchema.parse(req.body);
    const changedPasswordData = validation;

    const changeResult = await studentsService.processStudentPasswordChange(
      studentNum,
      changedPasswordData
    );

    return res.status(200).json(changeResult);
  } catch (error: any) {
    return handleControllerError(res, error, "STUDENT");
  }
}

export {
  getAllStudents,
  getStudentProfile,
  registerStudent,
  loginStudent,
  uploadProfilePicture,
  editStudentProfile,
  changeStudentPassword
}
