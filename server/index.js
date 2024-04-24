const express = require("express");
require("./config/database").connect();
const chatRoutes = require("./Routes/chatRoutes");
const messageRoutes = require("./Routes/messageRoutes");
const userRoutes = require("./Routes/userRoutes");
const Chat = require("./models/chatModels");

const app = express();
require("dotenv").config();

const port = process.env.PORT;

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
    origin: ["http://127.0.0.1:59936", "http://localhost:59936", "*"],
  },
}); // const io = require('socket.io')(server, {

io.use((socket, next) => {
  if (socket.handshake.query) {
    let callerId = socket.handshake.query.callerId;
    socket.user = callerId;
    next();
  }
});

const activeCalls = {};

io.on("connection", (socket) => {
  console.log("Connected to socket.io");
  console.log(socket.user, "Connected");
  socket.join(socket.user);

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
      const { chatId } = newMessageRecieved;

      if (!chatId) {
        console.log("chatId not defined");
        console.log("newMessageRecieved:", newMessageRecieved);
        return;
      }

      const chat = await Chat.findById(chatId).populate("users");

      console.log("Received message in chat:", chat);

      if (!chat || !chat.users) {
        console.log("chat or chat.users not defined");
        console.log("newMessageRecieved:", newMessageRecieved);
        return;
      }

      const sender = chat.users.find(
        (user) => user._id.toString() != newMessageRecieved.senderId.toString()
      );
      if (!sender) {
        console.log(
          "Sender not found in chat users:",
          newMessageRecieved.senderId
        );
        return;
      }

      const newMessageWithSenderName = {
        ...newMessageRecieved,
        senderName: sender.name,
      };

      chat.users.forEach((user) => {
        if (user._id.toString() !== newMessageRecieved.senderId.toString()) {
          socket
            .in(user._id.toString())
            .emit("message received", newMessageWithSenderName);
        }
      });
    } catch (error) {
      console.error("Error fetching chat:", error);
    }
  });

  // calling function
  socket.on("makeCall", (data) => {
    let calleeId = data.calleeId;
    let sdpOffer = data.sdpOffer;

    socket.to(calleeId).emit("newCall", {
      callerId: socket.user,
      sdpOffer: sdpOffer,
    });
  });

  socket.on("acceptCall", (data) => {
    const room = `${data.callerId}_${data.calleeId}`;
    socket.join(room);
    console.log("Accepted call from: ", data.callerId);

    if (!activeCalls[room]) {
      activeCalls[room] = {
        timer: 0,
        interval: setInterval(() => {
          // console.log(
          //   `Emitting timer update for room ${room}: ${activeCalls[room].timer}`
          // ),
          activeCalls[room].timer++;
          io.to(room).emit("timerUpdate", { timer: activeCalls[room].timer });
        }, 1000),
      };
    }
  });

  socket.on("endCall", (data) => {
    // console.log(data);
    const room = `${data.from}_${data.to}`;
    console.log(room);
    console.log(`Ending call from: ${data.from} in room: ${room}`);

    // Notify both the caller and the callee to end the call
    io.in(room).emit("callEnded", {
      from: data.from,
      to: data.to,
      message: "Call ended by the other party.",
    });

    // socket.leave(room);
    console.log("Ending call from: ", data.from);
    if (activeCalls[room]) {
      clearInterval(activeCalls[room].interval);
      delete activeCalls[room];
      io.to(room).emit("stopTimer");
    }
  });

  // socket.on("startTimer", (room) => {
  //   console.log("Starting timer for room: ", room);
  //   socket.to(room).emit("startTimer");
  // });
  socket.on("startTimer", (room) => {
    console.log("Starting timer for room: ", room);
    // Reset timer for the room
    if (!activeCalls[room]) {
      activeCalls[room] = { timer: 0, interval: null };
    }
    clearInterval(activeCalls[room].interval);
    activeCalls[room].timer = 0; // Reset timer to 0
    activeCalls[room].interval = setInterval(() => {
      activeCalls[room].timer++;
      io.to(room).emit("timerUpdate", { timer: activeCalls[room].timer });
    }, 1000);
  });

  socket.on("callRejected", (data) => {
    console.log(`Call rejected by ${data.from}, notifying ${data.to}`);

    // Notify the callee about the rejection
    socket.to(data.to).emit("callRejected", {
      from: data.from,
      reason: data.reason,
    });

    // Additionally, notify the caller so that both ends can clean up
    socket.to(data.from).emit("callRejected", {
      from: data.from,
      reason: data.reason,
    });
  });

  socket.on("answerCall", (data) => {
    let callerId = data.callerId;
    let sdpAnswer = data.sdpAnswer;

    socket.to(callerId).emit("callAnswered", {
      callee: socket.user,
      sdpAnswer: sdpAnswer,
    });
  });

  socket.on("IceCandidate", (data) => {
    let calleeId = data.calleeId;
    let iceCandidate = data.iceCandidate;

    socket.to(calleeId).emit("IceCandidate", {
      sender: socket.user,
      iceCandidate: iceCandidate,
    });
  });

  socket.on("disconnect", () => {
    console.log("Disconnected from socket.io");
    socket.leaveAll();
    socket.removeAllListeners();
    Object.keys(activeCalls).forEach((room) => {
      if (room.includes(socket.id)) {
        clearInterval(activeCalls[room].interval);
        delete activeCalls[room];
      }
    });
  });
});
