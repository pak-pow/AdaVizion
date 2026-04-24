/*
  Warnings:

  - You are about to alter the column `qr_string` on the `landmarks` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(255)`.

*/
-- AlterTable
ALTER TABLE "landmarks" ALTER COLUMN "qr_string" SET DATA TYPE VARCHAR(255);
