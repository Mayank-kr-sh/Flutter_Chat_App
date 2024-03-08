const jwt = require("jsonwebtoken");
const User = require("../models/userModel.js");
const asyncHandler = require("express-async-handler");

const protect = asyncHandler(async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    try {
      //gets token from header
      // it is in the format
      // Bearer token which is split by space and we get the token
      // example: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwMzE5YzI2Yjg2NzYwMzY5YzE4MzIzZiIsImlhdCI6MTYxNjE5MzEzNywiZXhwIjoxNjE2MjAwMzM3fQ.9vJF1aYwF5w3rX7xv6fGtZjZ0b5vz3ZtjR8Y6W6y3ZM
      token = req.headers.authorization.split(" ")[1];

      //decodes token id
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = await User.findById(decoded.id).select("-password");

      next();
    } catch (error) {
      res.status(401);
      throw new Error("Not authorized, token failed");
    }
  }

  if (!token) {
    res.status(401);
    throw new Error("Not authorized, no token");
  }
});

module.exports = { protect };
