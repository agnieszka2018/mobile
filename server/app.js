const _ = require("./env");
const express = require("express");
const mongoose = require("mongoose");
const authRoutes = require("./routes/authRoutes");
const procedureRoutes = require("./routes/procedureRoutes");
const eventRoutes = require("./routes/eventRoutes");
const session = require("./middleware/session");

const app = express();

app.use(express.static("public"));
app.use(express.json());

mongoose
  .connect(process.env.MONGO_CONN_URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    useCreateIndex: true,
    useFindAndModify: false,
  })
  .then((result) => app.listen(3000))
  .catch((err) => console.log(err));

app.use(session);
app.use(authRoutes);
app.use(procedureRoutes);
app.use(eventRoutes);

module.exports = app;
