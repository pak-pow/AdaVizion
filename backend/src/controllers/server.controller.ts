import type { Request, Response } from "express";
import { handleControllerError } from "../lib/error-handler";
import * as serverService from "../services/server.service";

async function home(req: Request, res: Response) {
  return res.status(200).json({
    message: "Welcome to EUventure"
  });
}

async function checkHealth(req: Request, res: Response) {
  try {
    await Promise.all([
      serverService.checkPrisma(),
      serverService.checkSupabase()
    ])

    res.status(200).json({
      message: "EUventure server is healthy",
      status: {
        prisma: "ok",
        supabase: "ok"
      },
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    return handleControllerError(res, error, "SERVER");
  }
}

export {
  home,
  checkHealth
}
