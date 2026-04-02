import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";

const router = express.Router();

router.get("/", async (req: Request, res: Response) => {
  try {
    const landmarks = await prisma.landmark.findMany();
    res.json(landmarks);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch landmarks"
    });
  }
})

export default router;
