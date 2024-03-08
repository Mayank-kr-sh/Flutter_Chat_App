import 'package:chat_app/src/api/api_service.dart';
import 'package:chat_app/src/home/list_chat_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _passwordLoginController =
      TextEditingController();

  bool _isLogin = false;

  @override
  void initState() {
    super.initState();
  }

  final _nameformKey = GlobalKey<FormState>();
  final _emailformKey = GlobalKey<FormState>();
  final _passwordformKey = GlobalKey<FormState>();

  final _emailLoginformKey = GlobalKey<FormState>();
  final _passwordLoginformKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLogin
                    ? Column(
                        children: [
                          Form(
                            key: _emailLoginformKey,
                            child: TextFormField(
                              controller: _emailLoginController,
                              decoration: const InputDecoration(
                                labelText: 'Enter your Email',
                              ),
                              validator: (value) {
                                if (value == null || value.length < 9) {
                                  return 'Please enter email.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Form(
                            key: _passwordLoginformKey,
                            child: TextFormField(
                              controller: _passwordLoginController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Enter Password',
                              ),
                              validator: (value) {
                                if (value == null || value.length < 9) {
                                  return 'Enter At least 6 digit.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: const Text('Create Account'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_emailLoginformKey.currentState!
                                          .validate() ||
                                      _passwordLoginformKey.currentState!
                                          .validate()) {
                                    String email = _emailLoginController.text;
                                    String password =
                                        _passwordLoginController.text;

                                    print('user email: $email');
                                    print('user password: $password');

                                    var userData = await ApiService.loginUser(
                                        email, password);
                                    final authToken = userData['token'];

                                    print(userData);
                                    if (userData['_id'] != null) {
                                      print('Navigating to GroupScreen...');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ListScreen(authToken: authToken),
                                        ),
                                      );
                                      // }
                                    } else {
                                      print(
                                          'Error: User data is null or does not contain id');
                                    }
                                    _emailLoginController.clear();
                                    _passwordLoginController.clear();
                                  }
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Form(
                            key: _nameformKey,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Enter User Name',
                              ),
                              validator: (value) {
                                if (value == null || value.length < 3) {
                                  return 'Please enter your name.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Form(
                            key: _emailformKey,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Enter your Email',
                              ),
                              validator: (value) {
                                if (value == null || value.length < 9) {
                                  return 'Please enter email.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Form(
                            key: _passwordformKey,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Enter Password',
                              ),
                              validator: (value) {
                                if (value == null || value.length < 9) {
                                  return 'Enter At least 6 digit.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: const Text('Login'),
                              ),
                              const SizedBox(width: 15),
                              ElevatedButton(
                                onPressed: () async {
                                  print(_nameController.text);
                                  if (_nameformKey.currentState!.validate() ||
                                      _emailformKey.currentState!.validate() ||
                                      _passwordformKey.currentState!
                                          .validate()) {
                                    String name = _nameController.text;
                                    String email = _emailController.text;
                                    String password = _passwordController.text;

                                    var userData = await ApiService.createUser(
                                        name, email, password);

                                    if (userData) {
                                      print(userData);
                                      Navigator.pop(context);
                                      // }
                                    } else {
                                      print(
                                          'Error: User data is null or does not contain id');
                                    }
                                    _nameController.clear();
                                    _emailController.clear();
                                    _passwordController.clear();
                                  }
                                },
                                child: const Text('Create Account'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
