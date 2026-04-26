import dotenv from "dotenv";
import express, { type Request, type Response } from "express";
import cors from "cors";
import studentRouter from "./routes/students.route";
import landmarkRouter from "./routes/landmarks.route";
import quizRouter from "./routes/quizzes.route";
import achievementRouter from "./routes/achievements.route";
import * as serverController from "./controllers/server.controller";

dotenv.config();

const PORT = process.env.PORT || 3000;

const FRONTEND_ORIGIN = process.env.FRONTEND_ORIGIN || "http://localhost:5000";

const app = express();

app.use(cors({
  origin: FRONTEND_ORIGIN,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json()); // Allows routes to parse the body (JSON data)

app.get("/", serverController.home);

app.get("/health", serverController.checkHealth)

app.use("/students", studentRouter);
app.use("/landmarks", landmarkRouter);
app.use("/quizzes", quizRouter);
app.use("/achievements", achievementRouter);

app.listen(PORT, () => {
  console.log(`Server ready at: http://localhost:${PORT}`)
});
