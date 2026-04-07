/*
  Warnings:

  - Added the required column `program` to the `students` table without a default value. This is not possible if the table is not empty.
  - Added the required column `year_level` to the `students` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "students" ADD COLUMN     "program" VARCHAR(50) NOT NULL,
ADD COLUMN     "specialization" VARCHAR(50),
ADD COLUMN     "year_level" INTEGER NOT NULL;
