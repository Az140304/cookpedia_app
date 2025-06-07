import 'package:flutter/material.dart';
import 'package:cookpedia_app/pages/login_page.dart';
import 'package:cookpedia_app/utils/session_manager.dart';
// import 'package:tugas_3_mobile/services/location_service.dart'; // Your existing commented import
// import 'package:tugas_3_mobile/pages/location_test_page.dart'; // Your existing commented import
import 'package:cookpedia_app/utils/notification_service.dart'; // ADD THIS IMPORT

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize NotificationService
  await NotificationService().init(); // ADD THIS LINE

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookpedia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8B1E)),
        useMaterial3: true,
        fontFamily: 'Poppins', // Assuming you still want this font
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Or your initial route logic
      // routes: { // If you use named routes
      //   '/details': (context) => DetailsScreen(), // Example route for notification tap
      // },
      // navigatorKey: navigatorKey, // Optional: for navigating from notification tap handler
    );
  }
}

// Optional: GlobalKey for navigation from notification tap if needed
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();