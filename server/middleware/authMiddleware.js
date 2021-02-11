const requireAuth = (req, res, next) => {
  if (!req.session || !req.session.user) {
    if (req.session) {
      req.session.destroy();
    }
    res.status(401).json({ msg: "Session has expired" });
    return;
  }
  next();
};

module.exports = requireAuth;
