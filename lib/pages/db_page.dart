import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/database_helper.dart'; // Adjust path if necessary

class DatabaseStatusPage extends StatefulWidget {
  const DatabaseStatusPage({super.key});

  @override
  State<DatabaseStatusPage> createState() => _DatabaseStatusPageState();
}

class _DatabaseStatusPageState extends State<DatabaseStatusPage> {
  final dbHelper = DatabaseHelper.instance;
  bool? _isConnected; // Nullable boolean to represent three states: unknown, connected, not connected
  String _statusMessage = "Checking database connection...";

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    // Set initial message while checking
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        _isConnected = null; // Reset to unknown/checking state
        _statusMessage = "Checking database connection...";
      });
    }

    bool status = await dbHelper.isDatabaseConnected();

    if (mounted) { // Check again if the widget is still in the tree before calling setState
      setState(() {
        _isConnected = status;
        if (status) {
          _statusMessage = "Database is connected and open!";
        } else {
          _statusMessage = "Database is NOT connected. Check logs for errors.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Status"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isConnected == null)
              const CircularProgressIndicator() // Show loader while checking
            else if (_isConnected == true)
              Icon(Icons.check_circle, color: Colors.green[700], size: 80)
            else
              Icon(Icons.error, color: Colors.red[700], size: 80),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _checkConnection, // Button to re-check
              child: const Text("Re-check Connection"),
            ),
          ],
        ),
      ),
    );
  }
}