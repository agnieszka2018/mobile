const mongoose = require("mongoose");

const eventSchema = new mongoose.Schema(
  {
    hash: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: [true, "Please enter an event name"],
    },
    note: {
      type: String,
      required: [true, "Please enter a description"],
    },
    color: {
      type: Number,
      required: [true, "Please pick a color"],
    },
    fromdate: {
      type: String,
      required: [true, "Please enter a start date"],
    },
    todate: {
      type: String,
      required: [true, "Please enter a stop date"],
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  },
  { timestamps: true }
);

eventSchema.statics.addEvent = async function (
  hash,
  name,
  note,
  color,
  fromdate,
  todate,
  user_id
) {
  if (!hash || !name || !note || !color || !fromdate || !todate) {
    throw Error("Field cannot be empty!");
  }

  const event = await Event.create({
    hash: hash,
    name: name,
    note: note,
    color: color,
    fromdate: fromdate,
    todate: todate,
    user: user_id,
  });
  if (event) {
    return;
  }
  throw Error("Cannot create an event");
};

eventSchema.statics.updateEvent = async function (
  hash,
  name,
  note,
  color,
  fromdate,
  todate
) {
  if (!hash || !name || !note || !color || !fromdate || !todate) {
    throw Error("Field cannot be empty!");
  }

  const updatedEvent = await Event.updateOne(
    { hash: hash },
    { name: name, note: note, color: color, fromdate: fromdate, todate: todate }
  );
  if (updatedEvent) {
    return;
  }
  throw Error("Cannot update an event");
};

eventSchema.statics.deleteEvent = async function (hash) {
  if (!hash) {
    throw Error("Field cannot be empty!");
  }

  const deletedEvent = await Event.findOneAndDelete({ hash: hash });
  if (deletedEvent) {
    return;
  }
  throw Error("Cannot delete an event");
};

const Event = mongoose.model("event", eventSchema);
module.exports = Event;
