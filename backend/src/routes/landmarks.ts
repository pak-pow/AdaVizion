import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { authenticateToken } from "../middleware/auth.middleware";

const router = express.Router();

// LANDMARKS ROOT ENDPOINT
router.get("/", authenticateToken, async (req: Request, res: Response) => {
  try {
    const landmarks = await prisma.landmark.findMany();
    res.json(landmarks);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch landmarks"
    });
  }
})

// DETAIL ENDPOINT
router.get("/:id", authenticateToken, async (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const landmarkId = parseInt(req.params.id as string);

  try {
    const [landmark, visited] = await Promise.all([
      // Get landmark with the given landmarkId
      prisma.landmark.findUnique({
        where: { landmark_id: landmarkId }
      }),
      // Get the entry where the student visits that landmark
      prisma.landmarksVisited.findUnique({
        where: {
          student_number_landmark_id: {
            student_number: studentNum,
            landmark_id: landmarkId
          }
        }
      })
    ]);

    if (!landmark) {
      return res.status(404).json({
        error: "Landmark not found"
      });
    }

    if (!visited) {
      const { description, fun_fact, ...publicData } = landmark;
      return res.json({ ...publicData, is_unlocked: false });
    }

    return res.status(200).json({ ...landmark, is_unlocked: true });
  } catch (error) {
    res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

// VISIT ENDPOINT
router.post("/:id/visit", authenticateToken, async (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const landmarkId = parseInt(req.params.id as string);
  const XP_REWARD = 20; // Fixed value for each landmark

  try {
    // Get landmark with the given landmarkId
    const landmark = await prisma.landmark.findUnique({
      where: {
        landmark_id: landmarkId
      }
    });

    if (!landmark) {
      return res.status(404).json({
        error: "Invalid landmark"
      });
    }

    // Get the entry where the student visits that landmark
    const existingVisit = await prisma.landmarksVisited.findUnique({
      where: {
        student_number_landmark_id: {
          student_number: studentNum,
          landmark_id: landmarkId
        }
      }
    });

    if (existingVisit) {
      return res.status(400).json({
        error: "Landmark already visited"
      });
    }

    // If the landmark is not yet visited, create a new entry in landmarksVisited and increase the student's total XP in progress
    await prisma.$transaction([
      prisma.landmarksVisited.create({
        data: {
          student_number: studentNum,
          landmark_id: landmarkId
        }
      }),
      prisma.progress.update({
        where: {
          student_number: studentNum
        },
        data: {
          total_xp: {
            increment: XP_REWARD
          }
        }
      })
    ]);

    return res.status(200).json({
      message: "Scan and visit successful",
      xp_earned: XP_REWARD,
      fun_fact: landmark.fun_fact
    });
  } catch (error) {
    return res.status(500).json({
      error: "Failed to process scan"
    });
  }
})

export default router;
