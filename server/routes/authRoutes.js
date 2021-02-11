const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
const requireAuth = require("../middleware/authMiddleware");

router.post("/checkemail", authController.check_email);
router.post("/login", authController.login_post);
router.post("/register", authController.register_post);
router.get("/user", requireAuth, authController.user_get);
router.get("/logout", requireAuth, authController.logout_get);

router.post("/recover", authController.recover_password);
router.post("/reset/:token", authController.reset_password);
router.post("/updatepassword", requireAuth, authController.update_password);

module.exports = router;
