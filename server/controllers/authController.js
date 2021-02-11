const User = require("../models/User");

module.exports.login_post = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.login(email, password);
    req.session.user = user;
    req.session.syncProc = user.createdAt;
    req.session.syncEvent = user.createdAt;

    res.status(200).json({ user: user._id });
  } catch (err) {
    if (
      err.message === "incorrect email" ||
      err.message === "incorrect  password"
    ) {
      res.status(400).json({ message: err.message });
    } else {
      res.status(500).json({ message: "Internal Server Error" });
    }
  }
};

module.exports.check_email = async (req, res) => {
  try {
    await User.checkEmail(req.body.email);
    res.status(200).json({ message: "OK" });
  } catch (err) {
    res.status(400).json({ message: "E-mail is already registered" });
  }
};

module.exports.register_post = async (req, res) => {
  const { name, email, password, specialization } = req.body;
  try {
    const user = await User.create({
      name: name,
      email: email,
      password: password,
      specialization: specialization,
    });
    req.session.user = user;
    req.session.syncProc = new Date().toISOString();
    req.session.syncEvent = new Date().toISOString();

    res.status(200).json({ user: user._id });
  } catch (err) {
    res.status(500).json({ message: "Internal Server Error" });
  }
};

module.exports.recover_password = async (req, res) => {
  try {
    const user = await User.findOne({ email: req.body.email });
    if (!user)
      return res.status(401).json({ message: "E-mail does not exist" });

    user.generateResetPasswordToken();
    user.save();

    const subject = "Reset hasła";
    const text = `Cześć ${user.name},\nproszę wklej ten token do aplikacji mobilnej:\n${user.resetPasswordToken}`;
    await user.sendEmail(subject, text);

    res.status(200).json({
      message: `A reset email has been send to ${user.email}.`,
    });
  } catch (err) {
    res.status(500).json({ message: "Internal Server Error" });
  }
};

module.exports.reset_password = async (req, res) => {
  try {
    const user = await User.findOne({
      resetPasswordToken: req.params.token,
      resetPasswordExpiry: { $gt: Date.now() },
    });

    if (!user)
      return res
        .status(401)
        .json({ message: `Password reset token is invalid or has expired` });

    user.password = req.body.password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpiry = undefined;
    user.save();

    const subject = "Hasło zostało zmienione";
    const text = `Cześć ${user.name},\nTwoje hasło zostało zmienione.`;
    await user.sendEmail(subject, text);

    res.status(200).json({
      message: "Your password has been updated",
    });
  } catch (err) {
    res.status(500).json({ message: "Internal Server Error" });
  }
};

module.exports.update_password = async (req, res) => {
  const { oldpassword, newpassword } = req.body;
  const email = req.session.user.email;

  try {
    const user = await User.login(email, oldpassword);
    user.password = newpassword;
    user.save();
    res.status(200).json({ message: "Your password has been updated" });
  } catch (err) {
    if (err.message === "incorrect  password") {
      res.status(400).json({ message: err.message });
    } else {
      res.status(500).json({ message: "Internal Server Error" });
    }
  }
};

module.exports.user_get = (req, res) => {
  try {
    let user = req.session.user;

    res.status(200).json({
      msg: "OK",
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        specialization: user.specialization,
      },
    });
  } catch (err) {
    res.status(500).json({ message: "Internal Server Error" });
  }
};

module.exports.logout_get = (req, res) => {
  try {
    req.session.destroy();
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ message: "Internal Server Error" });
  }
};
