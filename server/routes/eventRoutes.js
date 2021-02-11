const express = require("express");
const router = express.Router();
const eventController = require("../controllers/eventController");
const requireAuth = require("../middleware/authMiddleware");

router.post("/events", requireAuth, eventController.event_post);
router.get("/events", requireAuth, eventController.event_get);
router.put("/events", requireAuth, eventController.event_put);
router.delete("/events/:hash", requireAuth, eventController.event_delete);

module.exports = router;
