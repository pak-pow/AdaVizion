import express from "express";
import { prisma } from "../lib/prisma";

const router = express.Router();

router.get("/", async (req, res) => {
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
