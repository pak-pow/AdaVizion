/*
  Warnings:

  - Added the required column `tier` to the `achievements` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "achievements" ADD COLUMN     "tier" INTEGER NOT NULL;
