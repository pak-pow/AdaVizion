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

    const { landmark, visit } = await landmarksService.fetchLandmark(studentNum, landmarkId);

    if (!visit) {
      const { fun_fact, qr_string, ...publicData } = landmark;
      return res.status(403).json({ ...publicData, is_unlocked: false });
    }

    return res.status(200).json({ ...landmark, is_unlocked: true });
  } catch (error: any) {
    return handleControllerError(res, error, LANDMARK_ERRORS);
  }
}

async function visitLandmark(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const landmarkId = parseInt(req.params.id as string);
    const { qr_code_scanned } = req.body;

    const {
      landmark,
      newVisit,
      updatedProgress,
      XP_REWARD,
      achievementsEarned
    } = await landmarksService.processLandmarkVisit(studentNum, landmarkId, qr_code_scanned);

    const { qr_string, ...publicData } = landmark; // Exclude qr_string from response

    return res.status(200).json({
      message: "Scan and visit successful",
      ...publicData,
      visited_at: newVisit.visited_at,
      xp_earned: XP_REWARD,
      new_total_xp: updatedProgress.total_xp,
      new_achievements: achievementsEarned
    });
  } catch (error: any) {
    return handleControllerError(res, error, LANDMARK_ERRORS);
  }
}

export {
  getLandmarkChecklist,
  getLandmark,
  visitLandmark
}
