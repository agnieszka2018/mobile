const mongoose = require("mongoose");
const { isEmail } = require("validator");
const bcrypt = require("bcrypt");
const Procedure = require("./Procedure");
const Event = require("./Event");
const crypto = require("crypto");
const nodemailer = require("nodemailer");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Please enter a name"],
    },
    email: {
      type: String,
      required: [true, "Please enter an email"],
      unique: true,
      lowercase: true,
      trim: true,
      validate: [isEmail, "Please enter a valid email"],
    },
    password: {
      type: String,
      required: [true, "Please enter a password"],
      minlength: [6, "Password must be longer, at least 6 characters"],
      maxlength: [100, "Password must be shorter than 100 characters"],
    },
    specialization: {
      type: String,
      required: [true, "Please enter a specialization"],
      lowercase: true,
    },
    resetPasswordToken: {
      type: String,
      required: false,
    },
    resetPasswordExpiry: {
      type: Date,
      required: false,
    },
  },
  { timestamps: true }
);

userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt();
  this.password = await bcrypt.hash(this.password, salt);

  if (this.password) {
    next();
  } else {
    next(err);
  }
});

userSchema.statics.checkEmail = async function (email) {
  const user = await this.findOne({ email: email });
  if (!user) {
    return;
  }
  throw Error("Email is already registered");
};

userSchema.statics.login = async function (email, password) {
  const user = await this.findOne({ email: email });
  if (user) {
    const auth = await bcrypt.compare(password, user.password);
    if (auth) {
      return user;
    }
    throw Error("incorrect  password");
  }
  throw Error("incorrect email");
};

userSchema.methods.generateResetPasswordToken = function () {
  this.resetPasswordToken = crypto.randomBytes(20).toString("hex");
  this.resetPasswordExpiry = Date.now() + 1800000; // 30 minutes
};

userSchema.methods.sendEmail = async function (subject, text) {
  var transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
      type: "OAuth2",
      user: process.env.FROM_EMAIL,
      clientId: process.env.CLIENT_ID,
      clientSecret: process.env.CLIENT_SECRET,
      refreshToken: process.env.REFRESH_TOKEN,
      accessToken: process.env.ACCESS_TOKEN,
    },
  });

  const mail = {
    from: process.env.FROM_EMAIL,
    to: this.email,
    subject: subject,
    text: text,
  };

  const result = await transporter.sendMail(mail);
  if (!result) {
    throw Error("Cannot send an e-mail");
  }
};

userSchema.methods.getNewProcedures = async function (dateFrom, dateTo) {
  const procedures = await Procedure.find({
    user: this.id,
    updatedAt: { $gte: dateFrom, $lt: dateTo },
  });

  if (procedures) {
    return procedures;
  } else {
    throw Error("Cannot get new procedures");
  }
};

userSchema.methods.getAllProceduresHashes = async function () {
  const proceduresAll = await Procedure.find(
    {
      user: this.id,
    },
    { hash: 1, _id: 0 }
  );

  if (proceduresAll) {
    return proceduresAll;
  } else {
    throw Error("Cannot get all procedures' hashes");
  }
};

userSchema.methods.getNewEvents = async function (dateFrom, dateTo) {
  const events = await Event.find({
    user: this.id,
    updatedAt: { $gte: dateFrom, $lt: dateTo },
  });

  if (events) {
    return events;
  } else {
    throw Error("Cannot get new events");
  }
};

userSchema.methods.getAllEventsHashes = async function () {
  const eventsAll = await Event.find(
    {
      user: this.id,
    },
    { hash: 1, _id: 0 }
  );

  if (eventsAll) {
    return eventsAll;
  } else {
    throw Error("Cannot get all events' hashes");
  }
};

const User = mongoose.model("user", userSchema);
module.exports = User;
