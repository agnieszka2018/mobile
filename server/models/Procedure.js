const mongoose = require("mongoose");

const procedureSchema = new mongoose.Schema(
  {
    hash: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: [true, "Please enter a procedure name"],
    },
    quantity: {
      type: Number,
      required: [true, "Please enter a procedure number"],
    },
    completed: Boolean,
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  },
  { timestamps: true }
);

procedureSchema.statics.addProcedure = async function (
  hash,
  name,
  quantity,
  completed,
  user_id
) {
  if (!hash || !name || !quantity) {
    throw Error("Field cannot be empty!");
  }

  const proc = await Procedure.create({
    hash: hash,
    name: name,
    quantity: quantity,
    completed: completed,
    user: user_id,
  });
  if (proc) {
    return;
  }
  throw Error("Cannot create a procedure");
};

procedureSchema.statics.updateProcedure = async function (
  hash,
  name,
  quantity,
  completed
) {
  if (!hash || !name || !quantity) {
    throw Error("Field cannot be empty!");
  }

  const updatedProcedure = await Procedure.updateOne(
    { hash: hash },
    { name: name, quantity: quantity, completed: completed }
  );
  if (updatedProcedure) {
    return;
  }
  throw Error("Cannot update a procedure");
};

procedureSchema.statics.deleteProcedure = async function (hash) {
  if (!hash) {
    throw Error("Field cannot be empty!");
  }

  const deletedProcedure = await Procedure.findOneAndDelete({ hash: hash });
  if (deletedProcedure) {
    return;
  }
  throw Error("Cannot delete a procedure");
};

const Procedure = mongoose.model("procedure", procedureSchema);
module.exports = Procedure;
