import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reminderhome.dart';
import 'register.dart';
import '../entities/user.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  var obscurePassword = true;
  var isLoading = false;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  void _showMessage(String message) {
    final toDisplay = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(toDisplay);
  }

  void _togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  Future<User> _login(Uri url) async {
    final response = await http.post(url,
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'password': _passwordController.text
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).timeout(const Duration(seconds: 10), onTimeout: () {
      _showMessage('Timed out');
      throw Exception('Timed out');
    });
    final Map<String, dynamic> decodedJson = json.decode(response.body);
    if (response.statusCode == 200) {
      return User(
          decodedJson['user_id'].toString(), _emailController.text.toString());
    } else {
      _showMessage(decodedJson['message']);
      throw Exception('Failed to login');
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (Platform.isWindows) {
        final url = Uri.parse('http://localhost:8000/login');
        final user = await _login(url);
        _showMessage('Logged in as ${user.email}');
        if (mounted) {
          pushReminderHome(context, user);
        }
      } else {
        final url = Uri.parse('http://10.0.2.2:8000/login');
        final user = await _login(url);
        _showMessage('Logged in as ${user.email}');
        if (mounted) {
          pushReminderHome(context, user);
        }
      }
    } catch (e) {
      _showMessage('Failed to login');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void pushReminderHome(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReminderHome(user: user)),
    );
  }

  void pushRegisterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    hintText: 'Please enter your email here',
                  )),
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: 'Please enter your password here',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _togglePasswordVisibility();
                    },
                    icon: const Icon(Icons.visibility),
                  ),
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        handleLogin(context);
                      },
                      child: const Text('Login')),
              TextButton(
                  onPressed: () {
                    pushRegisterPage(context);
                  },
                  child: const Text(
                      'Don\'t have an account? Click here to register')),
            ],
          ),
        );
      }),
    );
  }
}
