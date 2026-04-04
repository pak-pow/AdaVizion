-- AlterTable
ALTER TABLE "quiz_submissions" ALTER COLUMN "quiz_id" DROP DEFAULT;
DROP SEQUENCE "quiz_submissions_quiz_id_seq";

-- CreateTable
CREATE TABLE "question_submissions" (
    "student_number" VARCHAR(20) NOT NULL,
    "quiz_id" INTEGER NOT NULL,
    "question_id" INTEGER NOT NULL,
    "selected_idx" INTEGER NOT NULL,

    CONSTRAINT "question_submissions_pkey" PRIMARY KEY ("student_number","quiz_id","question_id")
);

-- AddForeignKey
ALTER TABLE "question_submissions" ADD CONSTRAINT "question_submissions_student_number_fkey" FOREIGN KEY ("student_number") REFERENCES "students"("student_number") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_submissions" ADD CONSTRAINT "question_submissions_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("question_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_submissions" ADD CONSTRAINT "question_submissions_student_number_quiz_id_fkey" FOREIGN KEY ("student_number", "quiz_id") REFERENCES "quiz_submissions"("student_number", "quiz_id") ON DELETE RESTRICT ON UPDATE CASCADE;
