import express from "express";
import studentRouter from "./routes/students";
import landmarkRouter from "./routes/landmarks";

const app = express();

// To run this file, execute `npm run dev` in terminal

app.get("/", (req, res) => {
  res.json({
    status: "ok",
    message: "EUventure API is running"
  });
})

app.use("/students", studentRouter);
app.use("/landmarks", landmarkRouter);

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server ready at: http://localhost:${PORT}`)
});
