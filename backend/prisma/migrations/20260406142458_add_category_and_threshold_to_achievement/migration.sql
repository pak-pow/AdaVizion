/*
  Warnings:

  - You are about to drop the column `name` on the `achievements` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[title]` on the table `achievements` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `category` to the `achievements` table without a default value. This is not possible if the table is not empty.
  - Added the required column `threshold` to the `achievements` table without a default value. This is not possible if the table is not empty.
  - Added the required column `title` to the `achievements` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "AchievementCategory" AS ENUM ('EXPLORER', 'SCHOLAR');

-- AlterTable
ALTER TABLE "achievements" DROP COLUMN "name",
ADD COLUMN     "category" "AchievementCategory" NOT NULL,
ADD COLUMN     "threshold" INTEGER NOT NULL,
ADD COLUMN     "title" VARCHAR(100) NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "achievements_title_key" ON "achievements"("title");
