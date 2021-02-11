const mongoose = require("mongoose");
const User = require("../models/User");
const chai = require("chai");
const chaiHttp = require("chai-http");
const app = require("../app");
const should = chai.should();

chai.use(chaiHttp);
let mycookie;

before((done) => {
  User.findOneAndDelete({ email: "test@gmail.com" }, (err) => {
    done();
  });
});

describe("1) user tests", () => {
  describe("POST /register and GET /user", () => {
    it("it should register and then log in a user", (done) => {
      chai
        .request(app)
        .post("/register")
        .set("content-type", "application/json")
        .send({
          name: "Test",
          email: "test@gmail.com",
          password: "123456",
          specialization: "pediatria",
        })

        .end((err, res) => {
          res.should.have.status(200);
          mycookie = res.headers["set-cookie"][0];
          return chai
            .request(app)
            .get("/user")
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

  describe("POST /updatepassword", () => {
    it("it should update a password", (done) => {
      chai
        .request(app)
        .post("/updatepassword")
        .set("Cookie", mycookie)
        .set("content-type", "application/json")
        .send({
          oldpassword: "123456",
          newpassword: "654321",
        })
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have
            .property("message")
            .eql("Your password has been updated");
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
