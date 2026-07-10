import { Router } from "express";
import * as eventController from "../controllers/event.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { createEventSchema, updateEventSchema } from "../dto/event.dto";

const router = Router();

router.use(authenticate);

router.get("/", eventController.getAllEvents);
router.get("/:id", eventController.getEventById);
router.post("/", validateRequest(createEventSchema), eventController.createEvent);
router.patch("/:id", validateRequest(updateEventSchema), eventController.updateEvent);
router.delete("/:id", eventController.deleteEvent);

export default router;
