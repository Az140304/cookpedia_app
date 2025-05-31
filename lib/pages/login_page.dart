import 'package:flutter/material.dart';
import 'package:cookpedia_app/pages/home2_page.dart';
import 'package:cookpedia_app/utils/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  void login() async {
    if (_usernameController.text == '123220042' &&
        _passwordController.text == 'fulan') {
      // save session
      await SessionManager.saveLoginSession(_usernameController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FoodListScreen(/*username: _usernameController.text*/),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau password salah")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome back,',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text('Login to enter your account',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person), labelText: 'Username'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock), labelText: 'Password'),

                obscureText: true,
              ),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: login,
                      child: const Text('Login')))
            ],
          ),
        ),
      ),
    );
  }
}
