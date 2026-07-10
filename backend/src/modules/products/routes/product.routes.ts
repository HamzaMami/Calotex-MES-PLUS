import { Router } from "express";
import * as productController from "../controllers/product.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { createProductSchema, updateProductSchema } from "../dto/product.dto";

const router = Router();

// Apply authentication middleware to all product routes
router.use(authenticate);

router.get("/", productController.getAllProducts);
router.get("/:id", productController.getProductById);
router.post("/", validateRequest(createProductSchema), productController.createProduct);
router.patch("/:id", validateRequest(updateProductSchema), productController.updateProduct);
router.delete("/:id", productController.deleteProduct);

export default router;
