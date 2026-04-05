import dotenv from "dotenv";
import express, { type Request, type Response } from "express";
import studentRouter from "./routes/students";
import landmarkRouter from "./routes/landmarks";
import quizRouter from "./routes/quizzes";

dotenv.config();

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

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server ready at: http://localhost:${PORT}`)
});
