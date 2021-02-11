const mongoose = require("mongoose");
const Event = require("../models/Event");
const chai = require("chai");
const chaiHttp = require("chai-http");
const app = require("../app");
const should = chai.should();

chai.use(chaiHttp);
let mycookie;

before((done) => {
  Event.findOneAndDelete({ hash: "0123456789" }, (err) => {
    done();
  });
});

describe("3) event tests", () => {
  describe("POST /login and POST /events", () => {
    it("it should first log in and then add an event", (done) => {
      chai
        .request(app)
        .post("/login")
        .set("content-type", "application/json")
        .send({
          email: process.env.FROM_EMAIL,
          password: "123456",
        })
        .end((err, res) => {
          res.should.have.status(200);
          mycookie = res.headers["set-cookie"][0];
          return chai
            .request(app)
            .post("/events")
            .set("Cookie", mycookie)
            .set("content-type", "application/json")
            .send({
              hash: "0123456789",
              name: "kurs",
              note: "numer kursu",
              color: 4293467747,
              fromdate: "2021-01-21T12:00:00.000Z",
              todate: "2021-01-22T12:00:00.000Z",
            })
            .end((err, res) => {
              res.should.have.status(200);
              res.body.should.have.property("msg").eql("OK");
              done();
            });
        });
    });
  });

  describe("GET /events", () => {
    it("it should get all events", (done) => {
      chai
        .request(app)
        .get("/events")
        .set("content-type", "application/json")
        .set("Cookie", mycookie)
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have.property("events");
          res.body.should.have.property("hashes");
          res.body.should.have.property("msg").eql("OK");
          done();
        });
    });
  });

  describe("PUT /events", () => {
    it("it should update an event", (done) => {
      chai
        .request(app)
        .put("/events")
        .set("Cookie", mycookie)
        .set("content-type", "application/json")
        .send({
          hash: "0123456789",
          name: "kurs update",
          note: "numer kursu update",
          color: 4293467747,
          fromdate: "2021-01-21T12:00:00.000Z",
          todate: "2021-01-22T12:00:00.000Z",
        })
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have.property("msg").eql("OK");
          done();
        });
    });
  });

  describe("DELETE /events/:hash", () => {
    it("it should delete an event", (done) => {
      chai
        .request(app)
        .delete("/events/0123456789")
        .set("Cookie", mycookie)
        .set("content-type", "application/json")
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have.property("msg").eql("OK");
          done();
        });
    });
  });

  describe("GET /logout", () => {
    it("it should log out a user", (done) => {
      chai
        .request(app)
        .get("/logout")
        .set("content-type", "application/json")
        .set("Cookie", mycookie)
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have.property("msg").eql("OK");
          done();
        });
    });
  });
});
