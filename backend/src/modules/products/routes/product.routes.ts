import { Router } from "express";
import * as productController from "../controllers/product.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { createProductSchema, updateProductSchema } from "../dto/product.dto";
import { authorize } from "../../auth/middleware/role.middleware";
import multer from "multer";

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, callback) => {
    const filename = file.originalname.toLowerCase();
    callback(
      null,
      file.fieldname === "assembly_pdf"
        ? file.mimetype === "application/pdf" || filename.endsWith(".pdf")
        : file.fieldname === "product_photo"
          ? file.mimetype === "image/png" || filename.endsWith(".png")
          : false,
    );
  },
});

// Apply authentication middleware to all product routes
router.use(authenticate);

router.get("/", productController.getAllProducts);
router.get("/:id", productController.getProductById);
router.post("/", authorize("admin", "engineer"), upload.fields([
  { name: "assembly_pdf", maxCount: 1 },
  { name: "product_photo", maxCount: 1 },
]), validateRequest(createProductSchema), productController.createProduct);
router.patch("/:id", authorize("admin", "engineer"), upload.fields([
  { name: "assembly_pdf", maxCount: 1 },
  { name: "product_photo", maxCount: 1 },
]), validateRequest(updateProductSchema), productController.updateProduct);
router.delete("/:id", authorize("admin", "engineer"), productController.deleteProduct);

export default router;
