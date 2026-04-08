import type { Request, Response } from "express";
import * as landmarksService from "../services/landmarks.service";
import { handleControllerError } from "../lib/error-handler";

async function getLandmarkChecklist(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const checklist = await landmarksService.fetchLandmarkChecklist(studentNum);

    return res.status(200).json(checklist);
  } catch (error: any) {
    return handleControllerError(res, error, "LANDMARK");
  }
}

async function getLandmark(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const landmarkId = parseInt(req.params.id as string);

    const landmark = await landmarksService.fetchLandmark(studentNum, landmarkId);

    return res.status(200).json(landmark);
  } catch (error: any) {
    return handleControllerError(res, error, "LANDMARK");
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
    return handleControllerError(res, error, "LANDMARK");
  }
}

export {
  getLandmarkChecklist,
  getLandmark,
  visitLandmark
}
