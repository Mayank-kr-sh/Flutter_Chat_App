import 'package:chat_app/src/api/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/src/group/message_model.dart';
import 'package:chat_app/src/widgets/other_message_widget.dart';
import 'package:chat_app/src/widgets/own_message_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GroupScreen extends StatefulWidget {
  final String authToken;
  String name;
  final String userId;
  final String chatId;
  GroupScreen({
    Key? key,
    required this.name,
    required this.userId,
    required this.authToken,
    required this.chatId,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  TextEditingController messageController = TextEditingController();
  late IO.Socket socket;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    initializeSocket();
  }

  void initializeSocket() async {
    socket = IO.io('http://10.0.5.212:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      if (widget.userId != null && widget.chatId != null) {
        socket.emit('setup', {'_id': widget.userId});
        print('user id: ${widget.userId}');
        print('object id: ${widget.chatId}');
        print('Setup Ready: ${socket.connected}');
        socket.emit('join chat', widget.chatId);
      } else {
        print('userId or chatId is null');
      }
    });

    socket.on('message received', (data) {
      print('Received message: $data');
      setState(() {
        messages.add(Message.fromJson(data));
      });
    });
    socket.connect();
    await fetchMessagesData();
  }

  Future<void> fetchMessagesData() async {
    try {
      List<Message> data =
          await ApiService.fetchMessages(widget.chatId, widget.authToken);
      setState(() {
        messages = data;
      });
    } catch (e) {
      print('Error fetching messages: $e');
      print('Error fetching messages stack trace: ${StackTrace.current}');
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Welcome ${widget.name}',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                Message message = messages[index];

                if (message.senderName == widget.name) {
                  return OwnMessages(
                      message: messages[index].messages,
                      name: messages[index].senderName);
                } else {
                  return OtherMessages(
                    message: messages[index].messages,
                    name: messages[index].senderName,
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message.....',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          String message = messageController.text;
                          if (message.isNotEmpty) {
                            print('Message Send : $message');

                            var data = await ApiService.sendMessage(
                              message,
                              widget.chatId,
                              widget.authToken,
                            );
                            print('data: $data');

                            if (data != null &&
                                data['_id'] != null &&
                                data['senderName'] != null &&
                                data['senderId'] != null &&
                                data['message'] != null) {
                              print('Message sent');
                              socket.emit('new message', {
                                '_id': data['_id'],
                                'message': message.toString(),
                                'chatId': widget.chatId,
                                'senderId': widget.userId,
                                'senderName': widget.name,
                              });
                              print(data);
                              messageController.clear();
                              setState(() {
                                messages.add(Message(
                                  id: data['_id'],
                                  messages: data['message'],
                                  senderName: data['senderName'],
                                  chatId: data['chatId'],
                                  senderId: data['senderId'],
                                ));
                              });
                              messageController.clear();
                            } else {
                              print(
                                  'Error: User data is null or does not contain necessary fields');
                            }
                          }
                          messageController.clear();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
