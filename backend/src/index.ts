import { prisma } from "./lib/prisma";

// To run this file, execute `npm run dev` in termonal

async function main() {
  // Create a new student with a post
  const student = await prisma.student.create({
    data: {
      student_number: "A24-67676",
      first_name: "Juan",
      last_name: "Dela Cruz",
      email: "a24-67676@student.mseuf.edu.ph"
    }
  });
  console.log("Created student:", student);

  // Fetch all students
  const allStudents = await prisma.student.findMany();
  console.log("All students:", JSON.stringify(allStudents, null, 2));
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
