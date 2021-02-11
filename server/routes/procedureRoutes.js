const express = require("express");
const router = express.Router();
const procedureController = require("../controllers/procedureController");
const requireAuth = require("../middleware/authMiddleware");

router.post("/procedures", requireAuth, procedureController.procedure_post);
router.get("/procedures", requireAuth, procedureController.procedure_get);
router.put("/procedures", requireAuth, procedureController.procedure_put);
router.delete(
  "/procedures/:hash",
  requireAuth,
  procedureController.procedure_delete
);

module.exports = router;
