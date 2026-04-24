/*
  Warnings:

  - A unique constraint covering the columns `[question_text]` on the table `questions` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "questions_question_text_key" ON "questions"("question_text");
