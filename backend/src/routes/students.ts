import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { RegistrationSchema, LoginSchema } from "../schemas/student.schema";
import { authenticateToken } from "../middleware/auth.middleware";

const router = express.Router();

// STUDENTS ROOT ENDPOINT
router.get("/", authenticateToken, async (req: Request, res: Response) => {
  try {
    const students = await prisma.student.findMany({
      select: {
        student_number: true,
        first_name: true,
        middle_name: true,
        last_name: true,
        program: true,
        specialization: true,
        year_level: true,
        email: true,
        // Password omitted
        created_at: true
      }
    });
    res.status(200).json(students);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch students"
    });
  }
})

// REGISTER ENDPOINT
router.post("/register", async (req: Request, res: Response) => {
  // Validate with zod
  const validation = RegistrationSchema.safeParse(req.body);
  
  if (!validation.success) {
    return res.status(400).json({
      error: validation.error?.issues[0]?.message
    });
  }

  const {
    studentNum,
    firstName,
    middleName,
    lastName,
    program,
    specialization,
    yearLevel,
    email,
    password
  } = validation.data;

  try {
    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const result = await prisma.$transaction(async (tx) => {
      // Create a new student in the database
      const newStudent = await tx.student.create({
        data: {
          student_number: studentNum,
          first_name: firstName,
          middle_name: middleName || null, // Explicitly convert undefined to null while zod turns "" to null
          last_name: lastName,
          program: program,
          specialization: specialization || null,
          year_level: yearLevel,
          email: email,
          password: hashedPassword // Save hashed version
        }
      })
      
      // Concurrently create a progress entry for the student
      await tx.progress.create({
        data: {
          student_number: studentNum
        }
      });

      return newStudent;
    })

    // Remove password from response
    const { password: _, ...studentData } = result;

    return res.status(201).json(studentData);
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

// LOGIN ENDPOINT
router.post("/login", async (req: Request, res: Response) => {
  // Validate with zod
  const validation = LoginSchema.safeParse(req.body);

  if (!validation.success) {
    return res.status(400).json({
      error: validation.error?.issues[0]?.message
    });
  }

  const { studentNum, password } = validation.data;

  try {
    // Get unique student that matches the given student number
    const student = await prisma.student.findUnique({
      where: { student_number: studentNum },
      include: { progress: true }
    });

    if (!student) {
      return res.status(401).json({
        error: "Student does not exist"
      });
    }

    // Check if password input matches with hashed password in the database
    const isMatch = await bcrypt.compare(password, student.password);

    if (!isMatch) {
      return res.status(401).json({
        error: "Invalid student number or password"
      });
    }

    // Get authentication token
    const token = jwt.sign(
      { studentNum: studentNum },
      process.env.JWT_SECRET as string,
      { expiresIn: '1h' }
    )

    // Remove password from response
    const { password: _, ...studentData } = student;

    return res.status(200).json({
      message: "Login successful",
      token: token,
      student: studentData
    });
  } catch (error) {
    return res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

export default router;
