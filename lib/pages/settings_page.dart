import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/session_manager.dart'; // For SessionManager
import 'package:cookpedia_app/pages/login_page.dart';    // To navigate to LoginPage

class SettingsPage extends StatelessWidget {
  final String? username;
  final int? userId;

  const SettingsPage({
    super.key,
    this.username,
    this.userId,
  });

  Future<void> _logout(BuildContext context) async {
    await SessionManager.clearSession();
    // Ensure context is still valid if this widget could be disposed
    // For a StatelessWidget, context should be valid during its build method's scope.
    // If this were in a long-running async operation in a StatefulWidget, a 'mounted' check would be good.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, // Remove all routes below LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Automatically implies a back button if pushed onto navigation stack
        // If it's a root page in a tab, no back button is fine.
      ),
      body: ListView( // Using ListView for easy extension with more settings items
        children: <Widget>[
          // Display User Info (Optional)
          if (username != null || userId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User Information",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (username != null) Text("Username: $username"),
                  if (userId != null) Text("User ID: $userId"),
                  const Divider(height: 20, thickness: 1),
                ],
              ),
            ),

          // Placeholder for other settings
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account'),
            onTap: null, // TODO: Implement account settings page or action
          ),
          const ListTile(
            leading: Icon(Icons.notifications_none),
            title: Text('Notifications'),
            onTap: null, // TODO: Implement notification settings page or action
          ),
          const Divider(),

          // Logout Button in the form of a Row within an InkWell (or ListTile)
          InkWell(
            onTap: () {
              // Optional: Show a confirmation dialog before logging out
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Logout'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                          _logout(context); // Pass the main build context
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.logout, color: Colors.red[700]),
                  const SizedBox(width: 16),
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}