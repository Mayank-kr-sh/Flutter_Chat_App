const mongooes = require("mongoose");

const messagesModel = mongooes.Schema(
  {
    sender: {
      type: mongooes.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    chat: {
      type: mongooes.Schema.Types.ObjectId,
      ref: "Chat",
      required: true,
    },
  },
  { Timestamps: true }
);

module.exports = mongooes.model("Message", messagesModel);
