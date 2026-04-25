import { prisma } from "../lib/prisma";
import { supabase } from "../lib/supabase";
import type { EditProfileBody, RegistrationBody } from "../schemas/students.schema";

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

async function updateStudentPicture(
  studentNum: string,
  oldFilePath: string | null,
  fileName: string,
  fileBuffer: Buffer,
  mimeType: string
) {
  // Upload the new file first
  const { error } = await supabase
    .storage
    .from("student-avatars")
    .upload(fileName, fileBuffer, {
      contentType: mimeType,
      upsert: true,
    });
  
  if (error) {
    console.error("Supabase Storage Error:", error);
    throw new Error("Failed to upload profile picture");
  };
  
  // Get the new URL
  const { data } = supabase
    .storage
    .from("student-avatars")
    .getPublicUrl(fileName);

  if (!data) {
    throw new Error("Profile picture not found");
  }

  // Update the database
  const updatedStudent = await prisma.student.update({
    where: { student_number: studentNum },
    data: { img_path: data.publicUrl }
  });

  // Delete the old file only after the new one is safely linked
  if (updatedStudent && oldFilePath) {
    const { error } = await supabase
      .storage
      .from("student-avatars")
      .remove([oldFilePath]);

    if (error) {
      console.error(`Failed to delete old file ${oldFilePath}:`, error);
    };
  }

  return updatedStudent;
}

async function updateStudentProfile(
  studentNum: string,
  updatedProfileData: EditProfileBody
) {
  return await prisma.student.update({
    where: { student_number: studentNum },
    data: {
      first_name: updatedProfileData.firstName,
      middle_name: updatedProfileData.middleName || null,
      last_name: updatedProfileData.lastName,
      program: updatedProfileData.program,
      specialization: updatedProfileData.specialization || null,
      year_level: updatedProfileData.yearLevel
    }
  });
}

async function updateStudentPassword(studentNum: string, newPassword: string) {
  return await prisma.student.update({
    where: { student_number: studentNum },
    data: { password: newPassword }
  });
}

export {
  findStudents,
  findStudent,
  findStudentProgress,
  createStudent,
  updateStudentPicture,
  updateStudentProfile,
  updateStudentPassword
}
