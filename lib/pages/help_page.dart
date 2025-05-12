import 'package:flutter/material.dart';
import 'package:cookpedia_app/pages/login_page.dart';
import 'package:cookpedia_app/utils/session_manager.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  void logout(BuildContext context) async {
    // clear session
    await SessionManager.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bantuan & Panduan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jika mengalami kendala, hubungi tim pengembang melalui email: support@app.com',
            style: TextStyle(fontSize: 16),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
