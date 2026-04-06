import dotenv from "dotenv";
import express, { type Request, type Response } from "express";
import studentRouter from "./routes/students.route";
import landmarkRouter from "./routes/landmarks.route";
import quizRouter from "./routes/quizzes.route";
import achievementRouter from "./routes/achievements.route";

dotenv.config();

const PORT = process.env.PORT || 3000;

const app = express();

app.use(express.json());

// To run this file, execute `npm run dev` in terminal

app.get("/", (req: Request, res: Response) => {
  res.json({
    status: "ok",
    message: "EUventure API is running"
  });
})

app.use("/students", studentRouter);
app.use("/landmarks", landmarkRouter);
app.use("/quizzes", quizRouter);
app.use("/achievements", achievementRouter);

app.listen(PORT, () => {
  console.log(`Server ready at: http://localhost:${PORT}`)
});
