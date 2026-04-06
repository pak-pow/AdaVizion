import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { authenticateToken } from "../middleware/auth.middleware";

const router = express.Router();

// User must be logged in to access these routes
router.use(authenticateToken);

// ACHIEVEMENTS ROOT ENDPOINT
router.get("/", async (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;

  try {
    const [allAchievements, achievementsEarned] = await Promise.all([
      // Get all available achievements in the database
      prisma.achievement.findMany(),

      // Get all achievements earned by the student
      prisma.achievementsEarned.findMany({
        where: { student_number: studentNum },
        select: { achievement_id: true }
      })
    ]);

    const earnedAchievementIds = new Set(achievementsEarned.map((achievement) => achievement.achievement_id));

    // Final list to show on the frontend
    const achievementList = allAchievements.map((achievement) => ({
      ...achievement,
      is_unlocked: earnedAchievementIds.has(achievement.achievement_id) // Flag for frontend to visually display unlocked status
    }));

    res.status(200).json(achievementList);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch achievements"
    });
  }
})

export default router;
