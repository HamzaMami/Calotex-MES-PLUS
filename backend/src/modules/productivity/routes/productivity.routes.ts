import { Router } from "express";
import multer from "multer";
import { authenticate } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import * as controller from "../controllers/productivity.controller";

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });
const router = Router();
const writers = [
  authenticate,
  authorize("admin", "ctx1_production_manager"),
];

router.get("/", authenticate, controller.list);
router.post("/records", ...writers, controller.save);
router.delete("/records/:year/:week", ...writers, controller.remove);
router.post("/upload", ...writers, upload.single("file"), controller.upload);

export default router;
