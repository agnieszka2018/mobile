const mongoose = require("mongoose");
const chai = require("chai");
const chaiHttp = require("chai-http");
const app = require("../app");
const should = chai.should();

chai.use(chaiHttp);

describe("2) sending an e-mail test", () => {
  describe("POST /recover", () => {
    it("it should send an e-mail", (done) => {
      chai
        .request(app)
        .post("/recover")
        .set("Content-Type", "application/json")
        .send({
          email: process.env.FROM_EMAIL,
        })
        .end((err, res) => {
          res.should.have.status(200);
          res.body.should.have
            .property("message")
            .eql(`A reset email has been send to ${process.env.FROM_EMAIL}.`);
          done();
        });
    });
  });
});
