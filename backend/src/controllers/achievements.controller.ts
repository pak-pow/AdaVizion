import type { Request, Response } from "express";
import * as achievementsService from "../services/achievements.service";
import { handleControllerError } from "../lib/error-handler";

async function getAchievementslist(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;

    const achievementsList = await achievementsService.fetchAchievementsList(studentNum);

    return res.status(200).json(achievementsList);
  } catch (error: any) {
    return handleControllerError(res, error, "ACHIEVEMENT");
  }
}

export {
  getAchievementslist
}
