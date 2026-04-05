import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { authenticateToken } from "../middleware/auth.middleware";
import type { LandmarkVisitBody, ViewLandmark } from "../types/landmarks.types";

const router = express.Router();

router.use(authenticateToken);

// LANDMARKS ROOT ENDPOINT
router.get("/", async (req: Request, res: Response) => {
  try {
    const landmarks: ViewLandmark[] = await prisma.landmark.findMany();
    res.status(200).json(landmarks);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch landmarks"
    });
  }
})

// DETAIL ENDPOINT
router.get("/:id", async (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const landmarkId = parseInt(req.params.id as string);

  try {
    const [landmark, visited] = await Promise.all([
      // Get landmark with the given landmarkId
      prisma.landmark.findUnique({
        where: { landmark_id: landmarkId },
        select: {
          name: true,
          description: true,
          fun_fact: true
        }
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
      return res.status(403).json({ ...publicData, is_unlocked: false });
    }

    return res.status(200).json({ ...landmark, is_unlocked: true });
  } catch (error) {
    res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

// VISIT ENDPOINT
router.post("/:id/visit", async (req: Request<{id: string}, any, LandmarkVisitBody>, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const landmarkId = parseInt(req.params.id as string);
  const { qr_code_scanned } = req.body;

  const XP_REWARD = 20; // Fixed value for each landmark

  try {
    // Get landmark with the given landmarkId
    const landmark = await prisma.landmark.findUnique({
      where: {
        landmark_id: landmarkId
      },
      select: {
        name: true,
        description: true,
        fun_fact: true,
        qr_string: true
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

    if (landmark.qr_string !== qr_code_scanned) {
      return res.status(403).json({
        error: "Invalid landmark QR code"
      });
    }

    // If the landmark is not yet visited, create a new entry in landmarksVisited and increase the student's total XP in progress
    const [visit, updatedProgress] = await prisma.$transaction([
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

    const { qr_string, ...publicData } = landmark; // Exclude qr_string from response

    return res.status(200).json({
      message: "Scan and visit successful",
      ...publicData,
      xp_earned: XP_REWARD,
      new_total_xp: updatedProgress.total_xp
    });
  } catch (error) {
    return res.status(500).json({
      error: "Failed to process scan"
    });
  }
})

export default router;
