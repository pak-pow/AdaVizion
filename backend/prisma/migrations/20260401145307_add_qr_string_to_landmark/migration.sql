/*
  Warnings:

  - A unique constraint covering the columns `[qr_string]` on the table `landmarks` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `qr_string` to the `landmarks` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "landmarks" ADD COLUMN     "qr_string" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "landmarks_qr_string_key" ON "landmarks"("qr_string");
