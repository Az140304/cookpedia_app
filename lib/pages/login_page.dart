import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/database_helper.dart';
import 'package:cookpedia_app/utils/session_manager.dart';
import 'package:cookpedia_app/models/user_model.dart';
import 'register_page.dart'; // To navigate to register page
import 'main_page.dart'; // Assuming MainScreen is defined here or in main.dart and re-exported

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Key for the form to enable validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for the username and password text fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instance of DatabaseHelper for database operations
  final dbHelper = DatabaseHelper.instance;

  // Boolean to manage loading state and disable button during async operations
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    // Validate the form inputs
    if (_formKey.currentState!.validate()) {
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        _isLoading = true;
      });

      String username = _usernameController.text;
      String password = _passwordController.text;

      User? user = await dbHelper.getUserByUsername(username);

      if (!mounted) return; // Check mounted state after await

      if (user != null && user.password == password) {
        // WARNING: Plain text password comparison! In a real app, use hashed passwords.
        if (user.id != null) {
          await SessionManager.saveLoginSession(user.username, user.id!);
          if (mounted) { // Check mounted state before navigating
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()), // Navigate to MainScreen
            );
          }
        } else {
          // This case should ideally not happen if users are created correctly with an ID
          if (mounted) { // Check mounted state
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data is incomplete (missing ID).')),
            );
          }
        }
      } else {
        // Handle invalid username or password
        if (mounted) { // Check mounted state
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password.')),
          );
        }
      }

      if (mounted) { // Check mounted state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}