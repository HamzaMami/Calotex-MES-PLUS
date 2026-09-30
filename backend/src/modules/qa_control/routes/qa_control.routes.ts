import { Router } from "express";
import {
  authenticate,
  validateQuery,
  validateRequest,
} from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import * as controller from "../controllers/qa_control.controller";
import { createSchema, listQuerySchema } from "../dto/qa_control.dto";

const router = Router();
const readers = [
  authenticate,
  authorize(
    "Admin",
    "admin",
    "QA Technician",
    "qa_technician",
    "Engineer",
    "engineer",
    "CTX-1 production manager",
    "CTX-1 technical team manager"
  ),
];

router.get("/", ...readers, validateQuery(listQuerySchema), controller.list);
router.post("/", ...readers, validateRequest(createSchema), controller.create);

export default router;
