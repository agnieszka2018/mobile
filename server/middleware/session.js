const session = require("express-session");
const MongoDBStore = require("connect-mongodb-session")(session);

const store = new MongoDBStore(
  {
    uri: process.env.MONGO_CONN_URL,
    databaseName: "specialization",
    collection: "mySessions",
    expires: 1000 * 60 * 60 * 24 * 365 * 10, // session expires (in milliseconds)
    connectionOptions: {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 10000,
    },
  },
  function (err) {
    if (err) return next(err);
  }
);

store.on("error", function (err) {
  if (err) return next(err);
});

module.exports = session({
  store: store,
  secret: process.env.SESSION_SECRET,
  saveUninitialized: false,
  resave: false,
  cookie: {
    secure: false,
    httpOnly: false,
    maxAge: 1000 * 60 * 60 * 24 * 365 * 10,
  },
});
