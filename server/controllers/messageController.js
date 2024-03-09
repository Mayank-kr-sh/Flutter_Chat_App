const asyncHandler = require("express-async-handler");
const Message = require("../models/messageModel");
const chat = require("../models/chatModels");
const User = require("../models/userModel");

const allMessages = asyncHandler(async (req, res) => {
  try {
    const messages = await Message.find({ chat: req.params.chatId })
      // .populate("sender", "name pic email")
      // .populate("chat", "content users");

      .populate({
        path: "sender",
        select: "_id name", // Specify the fields to populate for the sender
      })
      .populate({
        path: "chat",
        select: "_id", // Specify the fields to populate for the chat
      })
      .select("_id sender content chat")
      .exec();

    const formattedMessages = messages.map((chat) => ({
      _id: chat._id,
      senderId: chat.sender._id,
      senderName: chat.sender.name,
      message: chat.content,
      chatId: chat.chat._id,
    }));

    res.json(formattedMessages);
  } catch (error) {
    res.status(400);
    throw new Error(error.message);
  }
});

const sendMessage = asyncHandler(async (req, res) => {
  const { content, chatId } = req.body;

  if (!content || !chatId) {
    console.log("Invalid data passed into request");
    return res.sendStatus(400);
  }

  const sender = await User.findById(req.user._id);

  var newMessage = {
    sender: req.user._id,
    senderName: sender.name,
    content: content,
    chat: chatId,
  };

  try {
    var messages = await Message.create(newMessage);

    messages = await messages.populate("sender", "name ");
    messages = await messages.populate("chat", "content");
    messages = await User.populate(messages, {
      path: "chat.users",
      select: "name pic email",
    });

    await chat.findByIdAndUpdate(req.body.chatId, { latestMessage: messages });

    res.json({
      _id: messages._id,
      chatId: messages.chat._id,
      message: messages.content,
      senderId: req.user._id,
      senderName: messages.sender.name,
    });
  } catch (error) {
    res.status(400);
    throw new Error(error.message);
  }
});

module.exports = { allMessages, sendMessage };
