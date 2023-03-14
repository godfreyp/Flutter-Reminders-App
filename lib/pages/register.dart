import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
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

  Future<void> _register(Uri url) async {
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
    _showMessage(decodedJson['message']);
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to register');
    }
  }

  void handleRegister(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (Platform.isWindows) {
        await _register(Uri.parse('http://localhost:8000/register'));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        await _register(Uri.parse('http://10.0.2.2:8000/register'));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showMessage('Failed to register');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
        title: const Text('Register new account'),
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
                        handleRegister(context);
                      },
                      child: const Text('Register')),
            ],
          ),
        );
      }),
    );
  }
}
