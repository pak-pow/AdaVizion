import { z } from "zod";
import { PROGRAM_ABBREVIATIONS, PROGRAM_SPECIALIZATIONS } from "../constants/academic-maps";

const studentNumBase = z.string({ error: "Student number must be a string" })
  .min(1, { error: "Student number is required" })
  .max(20, { error: "Student number cannot exceed 20 characters" })
  .toUpperCase()

const firstNameBase = z.string({ error: "First name must be a string" })
  .min(1, { error: "First name is required" })
  .max(50, { error: "First name cannot exceed 50 characters" })

const middleNameBase = z.string({ error: "Middle name must be a string" })
  .max(50, { error: "Middle name cannot exceed 50 characters" })
  .nullable()
  .optional()
  .transform((val) => val === "" ? null : val)

const lastNameBase = z.string({ error: "Last name must be a string" })
  .min(1, { error: "Last name is required" })
  .max(50, { error: "Last name cannot exceed 50 characters" })

const programBase = z.string({ error: "Program must be a string" })
  .min(1, { error: "Program is required" })
  .max(50, { error: "Program cannot exceed 50 characters" })

const specializationBase = z.string({ error: "Specialization must be a string" })
  .max(50, { error: "Specialization cannot exceed 50 characters" })
  .nullable()
  .optional()
  .transform((val) => val === "" ? null : val)

const yearLevelBase = z.number({ error: "Year level must be a number" })
  .int({ error: "Year level must be a whole number" })
  .min(1, { error: "Year level must be at least 1" })
  .max(5, { error: "Year level cannot exceed 5" })

const emailBase = z.email({ error: "Email is required and must be a valid format" })
  .max(50, { error: "Email cannot exceed 50 characters" })
  .toLowerCase()
  .refine((val) => val.endsWith("@student.mseuf.edu.ph"), { error: "Must be a valid MSEUF student email address" })

const passwordBase = z.string({ error: "Password must be a string" })
  .min(8, { error: "Password requires a minimum of 8 characters" })
  .max(255, { error: "Password is too long" })

export const RegistrationSchema = z.object({
  studentNum: studentNumBase,
  firstName: firstNameBase,
  middleName: middleNameBase,
  lastName: lastNameBase,
  program: programBase,
  specialization: specializationBase,
  yearLevel: yearLevelBase,
  email: emailBase,
  password: passwordBase
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
  studentNum: studentNumBase,
  password: passwordBase
})

export const EditProfileSchema = z.object({
  firstName: firstNameBase,
  middleName: middleNameBase,
  lastName: lastNameBase,
  program: programBase,
  specialization: specializationBase,
  yearLevel: yearLevelBase,
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

export const EditPasswordSchema = z.object({
  oldPassword: z.string({ error: "Old password must be a string" })
    .min(1, { error: "Old password is required" })
    .max(255, { error: "Old password is too long" }),

  newPassword: passwordBase,

  confirmPassword: z.string({ error: "Confirm password must be a string" })
    .min(1, { error: "Please confirm your new password" })
    .max(255, { error: "Confirm password is too long" })
})

.refine((data) => {
  return data.newPassword === data.confirmPassword 
}, {
  error: "Passwords do not match",
  path: ["confirmPassword"]
})

type RegistrationBody = z.infer<typeof RegistrationSchema>;
type LoginBody = z.infer<typeof LoginSchema>;
type EditProfileBody = z.infer<typeof EditProfileSchema>;
type EditPasswordBody = z.infer<typeof EditPasswordSchema>;

export type {
  RegistrationBody,
  LoginBody,
  EditProfileBody,
  EditPasswordBody
}
