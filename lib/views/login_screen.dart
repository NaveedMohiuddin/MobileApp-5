import 'dart:convert';

import 'package:battleships/utils/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/first_page.dart';

bool isLoading = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            (isLoading) ? const CircularProgressIndicator() : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _login(context),
                  child: const Text('Log in'),
                ),
                TextButton(
                  onPressed: () => _register(context),
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> callApi(String route, data, {String token = ''}) async {
    Map<String, String> headers = {};
    headers['Content-Type'] = 'application/json';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return http.post(
      Uri.parse('http://165.227.117.48$route'),
      headers: headers,
      body: data,
    );
  }

  Future<void> _login(BuildContext context) async {
    try {
      final username = usernameController.text;
      final password = passwordController.text;

      String data = jsonEncode(
          <String, String>{"username": username, "password": password});

      isLoading = true;

      final response = await ApiHelper.callApi('/login', data);
      final jsonRes = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Successful login. Save the session token or user info.

        // parse the session token from the response header
        final sessionToken = jsonRes['access_token'];
        await SessionManager.setSessionToken(sessionToken, username);

        if (!mounted) return;

        // go to the main screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const FirstPage(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      print('An error occurred: $e');
    }

    isLoading = false;
  }

  Future<void> _register(BuildContext context) async {
    try {
      final username = usernameController.text;
      final password = passwordController.text;

      String data = jsonEncode(
          <String, String>{"username": username, "password": password});

      isLoading = true;

      final response = await ApiHelper.callApi('/register', data);
      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Successful login. Save the session token or user info.

        // parse the session token from the response header
        final sessionToken = jsonRes['access_token'];
        await SessionManager.setSessionToken(sessionToken, username);

        if (!mounted) return;

        // go to the main screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const FirstPage(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      // print('An error occurred: $e');
    }

    isLoading = false;
  }
}
