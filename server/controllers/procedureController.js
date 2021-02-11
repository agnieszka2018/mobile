const User = require("../models/User");
const Procedure = require("../models/Procedure");

module.exports.procedure_get = async (req, res) => {
  let user;
  let dateFrom;
  let dateTo;

  try {
    user = await User.findById(req.session.user._id);
    dateFrom = req.session.syncProc;
    dateTo = new Date().toISOString();

    let procedures = await user.getNewProcedures(dateFrom, dateTo);
    let hashes = await user.getAllProceduresHashes();
    req.session.syncProc = dateTo;

    res.status(200).json({
      msg: "OK",
      procedures: procedures,
      hashes: hashes,
    });
  } catch (err) {
    req.session.syncProc = dateFrom;

    res.status(500).json({ msg: "Internal Server Error" });
  }
};

module.exports.procedure_post = async (req, res) => {
  try {
    let user = await User.findById(req.session.user._id);
    await Procedure.addProcedure(
      req.body.hash,
      req.body.name,
      req.body.quantity,
      req.body.completed,
      user._id
    );
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error" });
  }
};

module.exports.procedure_put = async (req, res) => {
  try {
    await Procedure.updateProcedure(
      req.body.hash,
      req.body.name,
      req.body.quantity,
      req.body.completed
    );
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error" });
  }
};

module.exports.procedure_delete = async (req, res) => {
  try {
    await Procedure.deleteProcedure(req.params.hash);
    res.status(200).json({ msg: "OK" });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error" });
  }
};
