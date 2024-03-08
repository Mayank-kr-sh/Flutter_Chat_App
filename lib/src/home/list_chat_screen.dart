import 'package:chat_app/src/api/api_service.dart';
import 'package:chat_app/src/group/chat_screen.dart';
import 'package:chat_app/src/group/user_model.dart';
import 'package:flutter/material.dart';

class ListScreen extends StatefulWidget {
  final String authToken;
  const ListScreen({super.key, required this.authToken});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<User> _chatUsers = [];
  @override
  void initState() {
    super.initState();
    fetchUsersdata();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchUsersdata();
  }

  Future<void> fetchUsersdata() async {
    try {
      final List<User> users = await ApiService.fetchUsers(widget.authToken);
      setState(() {
        _chatUsers = users;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _createChatRoom(String userId) async {
    try {
      final createdChat = await ApiService.accessChat(widget.authToken, userId);
      print('Chat room created with ID: ${createdChat['_id']}');
      final chatUserName = createdChat['users'][1]['name'];
      print('Chat room created with user: $chatUserName');

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupScreen(
            chatId: createdChat['_id'],
            name: chatUserName,
            userId: userId,
            authToken: widget.authToken,
          ),
        ),
      );
    } catch (e) {
      // Handle error
      print('Error creating chat room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registered Users',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatUsers.length,
              itemBuilder: (context, index) {
                User user = _chatUsers[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text('E-mail : ${user.email}'),
                      onTap: () {
                        print('user is selected for chat: ,${user.id}');
                        _createChatRoom(user.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
