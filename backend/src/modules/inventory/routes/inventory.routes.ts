import { Router } from "express";
import * as inventoryController from "../controllers/inventory.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { createInventorySchema, updateInventorySchema } from "../dto/inventory.dto";

const router = Router();

router.use(authenticate);

router.get("/", inventoryController.getAllItems);
router.get("/:id", inventoryController.getItemById);
router.post("/", validateRequest(createInventorySchema), inventoryController.createItem);
router.patch("/:id", validateRequest(updateInventorySchema), inventoryController.updateItem);
router.delete("/:id", inventoryController.deleteItem);

export default router;
