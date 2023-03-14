import 'package:flutter/material.dart';
import '../entities/user.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class HandshakePage extends StatefulWidget {
  final User user;
  const HandshakePage({Key? key, required this.user}) : super(key: key);

  @override
  HandshakePageState createState() => HandshakePageState();
}

class HandshakePageState extends State<HandshakePage> {
  var obscurePassword = true;
  var isLoading = false;
  late final Uri handshakeUrl;
  late final TextEditingController _contactsAccountController;
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

  Future<void> _handleHandshake() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _handshake();
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handshake() async {
    final response = await http.post(handshakeUrl,
        body: jsonEncode(<String, String>{
          'r_user_id': widget.user.userID,
          'c_username': _contactsAccountController.text,
          'c_password': _passwordController.text,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).timeout(const Duration(seconds: 10), onTimeout: () {
      _showMessage('Timed out');
      throw Exception('Timed out');
    });
    if (response.statusCode == 200) {
      _showMessage('Handshake successful, please logout and login again');
    } else {
      _showMessage('Either Handshake failed or Handshake previously done');
      throw Exception('Failed to perform handshake');
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      handshakeUrl = Uri.parse('http://localhost:8002/handshake');
    } else {
      handshakeUrl = Uri.parse('http://10.0.2.2:8002/handshake');
    }
    _contactsAccountController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _contactsAccountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perform Handshake via Contacts Application'),
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  '''If you have the Contacts Application installed, you can 
                  perform a handshake with it here. By doing so, you can share 
                  your reminders with your contacts and vice versa!'''),
              TextField(
                  controller: _contactsAccountController,
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
                        _handleHandshake();
                      },
                      child: const Text('Handshake')),
            ],
          ),
        );
      }),
    );
  }
}
