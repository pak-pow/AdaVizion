import { z } from "zod";
import { PROGRAM_ABBREVIATIONS, PROGRAM_SPECIALIZATIONS } from "../constants/academic-maps";

export const RegistrationSchema = z.object({
  studentNum: z.string()
    .min(1, { error: "Student number is required" })
    .max(20, { error: "Student number cannot exceed 20 characters" })
    .toUpperCase(),

  firstName: z.string()
    .min(1, { error: "First name is required" })
    .max(50, { error: "First name cannot exceed 50 characters" }),

  middleName: z.string()
    .max(50, { error: "Middle name cannot exceed 50 characters" })
    .nullable()
    .optional()
    .transform((val) => val === "" ? null : val),
  
  lastName: z.string()
    .min(1, { error: "Last name is required" })
    .max(50, { error: "Last name cannot exceed 50 characters" }),

  program: z.string()
    .min(1, { error: "Program is required" })
    .max(50, { error: "Program cannot exceed 50 characters" }),

  specialization: z.string()
    .max(50, { error: "Specialization cannot exceed 50 characters" })
    .nullable()
    .optional()
    .transform((val) => val === "" ? null : val),

  yearLevel: z.number()
    .int({ error: "Year level must be a whole number" })
    .min(1, { error: "Year level must be at least 1" })
    .max(5, { error: "Year level cannot exceed 5" }),

  email: z.email({ error: "Email is required and must be a valid format" })
    .max(50, { error: "Email cannot exceed 50 characters" })
    .toLowerCase()
    .refine((val) => val.endsWith("@student.mseuf.edu.ph"), { error: "Must be a valid MSEUF student email address" }),

  password: z.string()
    .min(8, { error: "Password requires a minimum of 8 characters" })
    .max(255)
})

// It is MSEUF standard that email prefixes must be the student number
.refine((data) => {
  const emailPrefix = data.email.split("@")[0];
  return emailPrefix === data.studentNum.toLowerCase();
}, {
  error: "Email must match your student number",
  path: ["email"]
})

// Verify program exists in the university curriculum
.refine((data) => {
  return Object.keys(PROGRAM_ABBREVIATIONS).includes(data.program);
}, {
  error: "Please select a valid MSEUF academic program",
  path: ["program"]
})

// Verify specialization belongs to the selected program
.refine((data) => {
  if (!data.specialization) return true;
  const validSpecializations = PROGRAM_SPECIALIZATIONS[data.program] || [];
  return validSpecializations.includes(data.specialization);
}, {
  error: "Invalid specialization for the selected program",
  path: ["specialization"]
})

export const LoginSchema = z.object({
  studentNum: z.string()
    .min(1, { error: "Student number is required" })
    .max(20, { error: "Student number cannot exceed 20 characters" })
    .toUpperCase(),

  password: z.string()
    .min(8, { error: "Password requires a minimum of 8 characters" })
    .max(255)
})

type RegistrationBody = z.infer<typeof RegistrationSchema>;
type LoginBody = z.infer<typeof LoginSchema>;

export type {
  RegistrationBody,
  LoginBody
}
