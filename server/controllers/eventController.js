const User = require("../models/User");
const Event = require("../models/Event");

module.exports.event_get = async (req, res) => {
  let user;
  let dateFrom;
  let dateTo;

  try {
    user = await User.findById(req.session.user._id);
    dateFrom = req.session.syncEvent;
    dateTo = new Date().toISOString();

    let events = await user.getNewEvents(dateFrom, dateTo);
    let hashes = await user.getAllEventsHashes();
    req.session.syncEvent = dateTo;

    res.status(200).json({
      msg: "OK",
      events: events,
      hashes: hashes,
    });
  } catch (err) {
    req.session.syncEvent = dateFrom;

    res.status(500).json({ msg: "Internal Server Error" });
  }
};

module.exports.event_post = async (req, res) => {
  try {
    let user = await User.findById(req.session.user._id);
    await Event.addEvent(
      req.body.hash,
      req.body.name,
      req.body.note,
      req.body.color,
      req.body.fromdate,
      req.body.todate,
      user._id
    );
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error" });
  }
};

module.exports.event_put = async (req, res) => {
  try {
    await Event.updateEvent(
      req.body.hash,
      req.body.name,
      req.body.note,
      req.body.color,
      req.body.fromdate,
      req.body.todate
    );
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error" });
  }
};

module.exports.event_delete = async (req, res) => {
  try {
    await Event.deleteEvent(req.params.hash);
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error" });
  }
};
