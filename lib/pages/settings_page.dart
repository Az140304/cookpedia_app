import 'package:cookpedia_app/pages/clock_page.dart';
import 'package:cookpedia_app/pages/currency_converter_page.dart';
import 'package:cookpedia_app/pages/about_page.dart';
import 'package:cookpedia_app/pages/impression_page.dart';
import 'package:cookpedia_app/pages/login_page.dart';
import 'package:cookpedia_app/pages/reminder_settings_page.dart';
import 'package:cookpedia_app/utils/session_manager.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _logout(BuildContext context) async {
    await SessionManager.clearSession();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF8B1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8B1E),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Reminder Settings'),
            subtitle: const Text('Set the notification frequency'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReminderSettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency Converter'),
            subtitle: const Text('Convert between IDR, USD, and JPY'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyConverterPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.timelapse),
            title: const Text('Time Converter'),
            subtitle: const Text('Convert time between WIB, WITA, WIT, London'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClockPage()),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8B1E),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Developers'),
            subtitle: const Text('Meet the team'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeveloperPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Saran dan Kesan'),
            subtitle: const Text('Course review and feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImpressionPage()),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8B1E),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
