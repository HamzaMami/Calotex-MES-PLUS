import { Router } from "express";
import * as orderController from "../controllers/manufacturing_order.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { createManufacturingOrderSchema, updateManufacturingOrderSchema } from "../dto/manufacturing_order.dto";

const router = Router();

router.use(authenticate);

router.get("/", orderController.getAllOrders);
router.get("/:id", orderController.getOrderById);
router.post("/", validateRequest(createManufacturingOrderSchema), orderController.createOrder);
router.patch(
  "/:id",
  authorize("admin", "ctx1_production_manager"),
  validateRequest(updateManufacturingOrderSchema),
  orderController.updateOrder
);
router.delete("/:id", orderController.deleteOrder);

export default router;
