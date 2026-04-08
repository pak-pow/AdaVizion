import type { Request, Response } from "express";
import * as landmarksService from "../services/landmarks.service";
import { handleControllerError } from "../lib/error-handler";
import { LANDMARK_ERRORS } from "../constants/error-maps";

async function getLandmarkChecklist(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const checklist = await landmarksService.fetchLandmarkChecklist(studentNum);

    return res.status(200).json(checklist);
  } catch (error: any) {
    return handleControllerError(res, error, LANDMARK_ERRORS);
  }
}

async function getLandmark(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const landmarkId = parseInt(req.params.id as string);

    const landmark = await landmarksService.fetchLandmark(studentNum, landmarkId);

    return res.status(200).json(landmark);
  } catch (error: any) {
    return handleControllerError(res, error, LANDMARK_ERRORS);
  }
}

async function visitLandmark(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const landmarkId = parseInt(req.params.id as string);
    const { qr_code_scanned } = req.body;

    const newVisit = await landmarksService.processLandmarkVisit(studentNum, landmarkId, qr_code_scanned);

    return res.status(200).json(newVisit);
  } catch (error: any) {
    return handleControllerError(res, error, LANDMARK_ERRORS);
  }
}

export {
  getLandmarkChecklist,
  getLandmark,
  visitLandmark
}
