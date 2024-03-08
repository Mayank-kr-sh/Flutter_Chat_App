const express = require("express");
require("./config/database").connect();
const chatRoutes = require("./Routes/chatRoutes");
const messageRoutes = require("./Routes/messageRoutes");
const userRoutes = require("./Routes/userRoutes");

const app = express();
const port = 3000;

app.use(express.json());

app.get("/", (req, res) => {
  res.send("API is running ...");
});

// Define routes
app.use("/api/user", userRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/message", messageRoutes);

// Start server
const server = app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

const io = require("socket.io")(server, {
  pingTimeout: 60000,
  cors: {
    origin: ["*"],
  },
});

io.on("connection", (socket) => {
  console.log("Connected to socket.io");

  socket.on("setup", (userData) => {
    socket.join(userData._id);
    socket.emit("connected");
  });

  socket.on("join chat", (room) => {
    socket.join(room);
    console.log("User Joined Room: " + room);
  });

  socket.on("new message", async (newMessageRecieved) => {
    try {
      const chatId = newMessageRecieved.chatId;

      if (!chatId) {
        console.log("chatId not defined");
        console.log("newMessageRecieved:", newMessageRecieved);
        return;
      }

      const chat = await chat.findById(chatId).populate("users");

      console.log("Received message in chat:", chat);

      if (!chat || !chat.users) {
        console.log("chat or chat.users not defined");
        console.log("newMessageRecieved:", newMessageRecieved);
        return;
      }

      chat.users.forEach((user) => {
        if (user._id.toString() !== newMessageRecieved.senderId.toString()) {
          socket
            .in(user._id.toString())
            .emit("message received", newMessageRecieved);
        }
      });
    } catch (error) {
      console.error("Error fetching chat:", error);
    }
  });

  socket.on("disconnect", () => {
    console.log("Disconnected from socket.io");
    socket.leaveAll();
    socket.removeAllListeners();
  });
});
