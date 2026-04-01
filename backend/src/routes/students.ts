import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import bcrypt from "bcrypt";

const router = express.Router();

router.get("/", async (req: Request, res: Response) => {
  try {
    const students = await prisma.student.findMany();
    res.json(students);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch students"
    });
  }
})

router.post("/register", async (req: Request, res: Response) => {
  const {
    studentNum,
    firstName,
    middleName,
    lastName,
    email,
    password
  } = req.body;

  if (!studentNum || !firstName || !lastName || !email || !password) {
    return res.status(400).json({
      error: "Missing required fields"
    });
  } 

  try {
    const result = await prisma.$transaction(async (tx) => {
      const newStudent = await tx.student.create({
        data: {
          student_number: studentNum,
          first_name: firstName,
          middle_name: middleName || null,
          last_name: lastName,
          email: email,
          password: password
        }
      })

      await tx.progress.create({
        data: {
          student_number: studentNum
        }
      });

      return newStudent;
    })

    return res.status(201).json(result);
  } catch (error: any) {
    if (error.code === "P2002") {
      return res.status(409).json({
        error: "Student number or email already exists"
      });
    }

    console.error(error);
    return res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

router.post("/login", async (req: Request, res: Response) => {
  const { studentNum, password } = req.body;

  if (!studentNum || !password) {
    return res.status(400).json({
      error: "Student number and password are required"
    });
  }

  try {
    const student = await prisma.student.findUnique({
      where: { student_number: studentNum },
      include: { progress: true }
    });

    if (!student) {
      return res.status(401).json({
        error: "Student does not exist"
      });
    }

    const isMatch = await bcrypt.compare(password, student.password);

    if (!isMatch) {
      return res.status(401).json({
        error: "Invalid credentials"
      });
    }

    const { password: _, ...studentData } = student;

    return res.status(200).json({
      message: "Login successful",
      student: studentData
    });
  } catch (error) {
    return res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

export default router;
