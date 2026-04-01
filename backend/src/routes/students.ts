import express from "express";
import { prisma } from "../lib/prisma";

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const students = await prisma.student.findMany();
    res.json(students);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch students"
    });
  }
})

export default router;
