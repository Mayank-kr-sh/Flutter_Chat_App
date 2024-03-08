const mongoose = require("mongoose");

require("dotenv").config();

const db = process.env.MONGODB_URI;

exports.connect = () => {
  mongoose
    .connect(db)
    .then(() => console.log("MongoDB connected"))
    .catch((err) => {
      console.log("MongoDB connection error's: ");
      console.log(err), process.exit(1);
    });
};
