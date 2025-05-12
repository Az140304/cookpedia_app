import 'package:flutter/material.dart';
import 'package:cookpedia_app/pages/home2_page.dart';
import 'package:cookpedia_app/pages/login_page.dart';
import 'package:cookpedia_app/utils/session_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas 3 Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: SessionManager.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final bool isLoggedIn = snapshot.data ?? false;
            if (isLoggedIn) {
              return FutureBuilder<String?>(
                future: SessionManager.getUsername(),
                builder: (context, usernameSnapshot) {
                  if(usernameSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    final String username = usernameSnapshot.data ?? 'Azhar Fikri';
                    return Home2Page(username: username);
                  }
                },
              );
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}
