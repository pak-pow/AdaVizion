import { prisma } from "../lib/prisma";
import type { RegistrationBody } from "../schemas/students.schema";

async function findStudents() {
  return await prisma.student.findMany({
    include: { 
      progress: {
        select: {
          total_xp: true,
          quiz_points: true,
          updated_at: true
        }
      }
    }
  });
}

async function findStudent(studentNum: string) {
  return await prisma.student.findUnique({
    where: { student_number: studentNum }
  });
}

async function findStudentProgress(studentNum: string) {
  return await prisma.progress.findUnique({
    where: { student_number: studentNum }
  });
}

async function createStudent(studentData: RegistrationBody) {
  return await prisma.$transaction(async (tx) => {
    // Create a new student in the database
    const newStudent = await tx.student.create({
      data: {
        student_number: studentData.studentNum,
        first_name: studentData.firstName,
        middle_name: studentData.middleName || null, // Explicitly convert undefined to null while zod turns "" to null
        last_name: studentData.lastName,
        program: studentData.program,
        specialization: studentData.specialization || null,
        year_level: studentData.yearLevel,
        email: studentData.email,
        password: studentData.password // Save hashed version
      }
    })
    
    // Concurrently create a progress entry for the student
    await tx.progress.create({
      data: {
        student_number: studentData.studentNum
      }
    });

    return newStudent;
  })
}

export {
  findStudents,
  findStudent,
  findStudentProgress,
  createStudent
}
