import { z } from "zod";

export const SubmitQuizSchema = z.object({
  answers: z.array(
    z.object({
      question_id: z.number()
        .int({ error: "Question ID must be a whole number" })
        .positive({ error: "Question ID must be a valid database ID" }),
      
      selected_idx: z.number()
        .int({ error: "Selected index must be a whole number" })
        .min(0, { error: "Selected index must be at least 0" })
        .max(3, { error: "Selection index cannot exceed 3 "})
    })
  )
})

type SubmitQuizBody = z.infer<typeof SubmitQuizSchema>;

export type { SubmitQuizBody }
