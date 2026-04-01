-- CreateTable
CREATE TABLE "students" (
    "student_number" VARCHAR(20) NOT NULL,
    "first_name" VARCHAR(50) NOT NULL,
    "middle_name" VARCHAR(50),
    "last_name" VARCHAR(50) NOT NULL,
    "email" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "students_pkey" PRIMARY KEY ("student_number")
);

-- CreateTable
CREATE TABLE "landmarks" (
    "landmark_id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "fun_fact" TEXT,

    CONSTRAINT "landmarks_pkey" PRIMARY KEY ("landmark_id")
);

-- CreateTable
CREATE TABLE "quizzes" (
    "quiz_id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "required_xp" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "quizzes_pkey" PRIMARY KEY ("quiz_id")
);

-- CreateTable
CREATE TABLE "questions" (
    "question_id" SERIAL NOT NULL,
    "quiz_id" INTEGER NOT NULL,
    "question_text" TEXT NOT NULL,
    "choices" JSONB NOT NULL,
    "correct_idx" INTEGER NOT NULL,
    "item_points" INTEGER NOT NULL DEFAULT 10,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("question_id")
);

-- CreateTable
CREATE TABLE "achievements" (
    "achievement_id" SERIAL NOT NULL,
    "name" VARCHAR(20) NOT NULL,
    "description" TEXT NOT NULL,

    CONSTRAINT "achievements_pkey" PRIMARY KEY ("achievement_id")
);

-- CreateTable
CREATE TABLE "landmarks_visited" (
    "student_number" VARCHAR(20) NOT NULL,
    "landmark_id" INTEGER NOT NULL,
    "visited_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "landmarks_visited_pkey" PRIMARY KEY ("student_number","landmark_id")
);

-- CreateTable
CREATE TABLE "quiz_submissions" (
    "student_number" VARCHAR(20) NOT NULL,
    "quiz_id" SERIAL NOT NULL,
    "score" INTEGER NOT NULL,
    "completed_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "quiz_submissions_pkey" PRIMARY KEY ("student_number","quiz_id")
);

-- CreateTable
CREATE TABLE "progress" (
    "student_number" VARCHAR(20) NOT NULL,
    "total_xp" INTEGER NOT NULL DEFAULT 0,
    "quiz_points" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "progress_pkey" PRIMARY KEY ("student_number")
);

-- CreateTable
CREATE TABLE "achievements_earned" (
    "student_number" VARCHAR(20) NOT NULL,
    "achievement_id" INTEGER NOT NULL,
    "earned_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "achievements_earned_pkey" PRIMARY KEY ("student_number","achievement_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "students_email_key" ON "students"("email");

-- CreateIndex
CREATE UNIQUE INDEX "landmarks_name_key" ON "landmarks"("name");

-- CreateIndex
CREATE UNIQUE INDEX "quizzes_name_key" ON "quizzes"("name");

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "quizzes"("quiz_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "landmarks_visited" ADD CONSTRAINT "landmarks_visited_student_number_fkey" FOREIGN KEY ("student_number") REFERENCES "students"("student_number") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "landmarks_visited" ADD CONSTRAINT "landmarks_visited_landmark_id_fkey" FOREIGN KEY ("landmark_id") REFERENCES "landmarks"("landmark_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quiz_submissions" ADD CONSTRAINT "quiz_submissions_student_number_fkey" FOREIGN KEY ("student_number") REFERENCES "students"("student_number") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quiz_submissions" ADD CONSTRAINT "quiz_submissions_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "quizzes"("quiz_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress" ADD CONSTRAINT "progress_student_number_fkey" FOREIGN KEY ("student_number") REFERENCES "students"("student_number") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "achievements_earned" ADD CONSTRAINT "achievements_earned_student_number_fkey" FOREIGN KEY ("student_number") REFERENCES "students"("student_number") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "achievements_earned" ADD CONSTRAINT "achievements_earned_achievement_id_fkey" FOREIGN KEY ("achievement_id") REFERENCES "achievements"("achievement_id") ON DELETE RESTRICT ON UPDATE CASCADE;
