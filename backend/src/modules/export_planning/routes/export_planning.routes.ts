import { Router } from "express";
import multer from "multer";
import { authenticate } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { validateRequest } from "../../auth/middleware/auth.midlleware";
import * as controller from "../controllers/export_planning.controller";
import { exportPlanSchema, updateExportPlanSchema } from "../dto/export_planning.dto";

const excelMimeTypes = new Set([
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "application/vnd.ms-excel",
  "application/octet-stream",
]);
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, callback) => {
    const extension = file.originalname.toLowerCase().endsWith(".xlsx");
    callback(null, extension && (excelMimeTypes.has(file.mimetype) || file.mimetype === ""));
  },
});

const router = Router();
router.get("/", authenticate, controller.list);
router.get("/:id", authenticate, controller.get);

const writers = [authenticate, authorize("admin", "ctx1_production_manager")];
router.delete("/clear", ...writers, controller.clearAll);
router.post("/", ...writers, validateRequest(exportPlanSchema), controller.create);
router.patch("/:id", ...writers, validateRequest(updateExportPlanSchema), controller.update);
router.put("/:id", ...writers, validateRequest(updateExportPlanSchema), controller.update);
router.delete("/:id", ...writers, controller.remove);
router.post("/preview", ...writers, upload.single("file"), controller.preview);
router.post("/upload", ...writers, upload.single("file"), controller.upload);

export default router;
