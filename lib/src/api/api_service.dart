import 'dart:convert';
import 'package:chat_app/src/group/message_model.dart';
import 'package:chat_app/src/group/user_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.5.212:3000';

  static Future createUser(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      print('User already exists');
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      print('User does not exist');
    } else {
      throw Exception('Failed to login user');
    }
  }

  static Future<List<User>> fetchUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((userJson) => User.fromJson(userJson)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  static Future accessChat(String token, String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'userId': id,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      print('User does not exist');
    } else {
      throw Exception('Failed to access chat room');
    }
  }

  static Future<List<Message>> fetchMessages(
      String chatId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/message/$chatId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Failed to fetch messages: $e');
    }
  }

  static Future sendMessage(String content, String chatId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/message'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'content': content,
        'chatId': chatId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      print('Failed to send message');
    } else {
      throw Exception('Unknown error in sending message');
    }
  }
}
