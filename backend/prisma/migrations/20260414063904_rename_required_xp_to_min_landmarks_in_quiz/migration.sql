/*
  Warnings:

  - You are about to drop the column `required_xp` on the `quizzes` table. All the data in the column will be lost.
  - Added the required column `min_landmarks` to the `quizzes` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "quizzes" DROP COLUMN "required_xp",
ADD COLUMN     "min_landmarks" INTEGER NOT NULL;
