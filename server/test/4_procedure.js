const mongoose = require("mongoose");
const Procedure = require("../models/Procedure");
const chai = require("chai");
const chaiHttp = require("chai-http");
const app = require("../app");
const should = chai.should();

chai.use(chaiHttp);
let mycookie;

before((done) => {
  Procedure.findOneAndDelete({ hash: "0123456789" }, (err) => {
    done();
  });
});

describe("4) procedure tests", () => {
  describe("POST /login and POST /procedures", () => {
    it("it should first log in and then add a procedure", (done) => {
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
            .post("/procedures")
            .set("Cookie", mycookie)
            .set("content-type", "application/json")
            .send({
              hash: "0123456789",
              name: "procedura",
              quantity: 1,
              completed: true,
            })
            .end((err, res) => {
              res.should.have.status(200);
              res.body.should.have.property("msg").eql("OK");
              done();
            });
        });
    });
  });

  describe("GET /procedures", () => {
    it("it should get all procedures", (done) => {
      chai
        .request(app)
        .get("/procedures")
        .set("content-type", "application/json")
        .set("Cookie", mycookie)
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have.property("procedures");
          res.body.should.have.property("hashes");
          res.body.should.have.property("msg").eql("OK");
          done();
        });
    });
  });

  describe("PUT /procedures", () => {
    it("it should update a procedure", (done) => {
      chai
        .request(app)
        .put("/procedures")
        .set("Cookie", mycookie)
        .set("content-type", "application/json")
        .send({
          hash: "0123456789",
          name: "procedura update",
          quantity: 2,
          completed: false,
        })
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have.property("msg").eql("OK");
          done();
        });
    });
  });

  describe("DELETE /procedures/:hash", () => {
    it("it should delete a procedure", (done) => {
      chai
        .request(app)
        .delete("/procedures/0123456789")
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
