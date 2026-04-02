import { z } from "zod";

export const RegistrationSchema = z.object({
  studentNum: z.string()
    .min(1, { error: "Student number is required" })
    .max(20, { error: "Student nunber cannot exceed 20 characters" }),

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

  email: z.email({ error: "Email is required and must be a valid format" })
    .max(50, { error: "Email cannot exceed 50 characters" })
    .refine((val) => val.endsWith("@student.mseuf.edu.ph"), { error: "Must be a valid MSEUF student email address" }),

  password: z.string()
    .min(8, { error: "Password requires a minimum of 8 characters" })
    .max(255)
})

export const LoginSchema = z.object({
  studentNum: z.string()
    .min(1, { error: "Student number is required" })
    .max(20, { error: "Student nunber cannot exceed 20 characters" }),

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
