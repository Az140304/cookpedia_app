import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/session_manager.dart'; // Import SessionManager
import 'package:cookpedia_app/pages/home_page.dart';      // Your FoodListScreen
import 'package:cookpedia_app/pages/search_page.dart';    // Your SearchPage
import 'package:cookpedia_app/pages/settings_page.dart';  // Your SettingsPage
import 'package:cookpedia_app/pages/shopping_note_page.dart'; // Your ShoppingNotePage

// Assuming ShoppingNotePage is modified to accept a userId parameter
// If ShoppingNotePage needs userId, its constructor should be like:
// const ShoppingNotePage({super.key, this.currentUserId});
// final int? currentUserId;

// Assuming SettingsPage might also want user info
// const SettingsPage({super.key, this.username, this.userId});

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _username;
  int? _userId;
  bool _isUserDataLoading = true; // To manage loading state for user data

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isUserDataLoading = true;
    });

    String? username = await SessionManager.getUsername();
    int? userId = await SessionManager.getUserId();

    if (mounted) {
      setState(() {
        _username = username;
        _userId = userId;
        _isUserDataLoading = false;
        print("MainScreen: User data loaded - UserID: $_userId, Username: $_username");
      });
    }
  }

  // Now _widgetOptions needs to be a getter or a method to access _userId and _username
  // This allows passing the loaded user data to the respective pages.
  List<Widget> _getWidgetOptions() {
    return <Widget>[
      const HomePage(), // Home page
      const SearchPage(),     // Search page
      ShoppingNotePage(currentUserId: _userId), // Pass userId to ShoppingNotePage
      // Ensure ShoppingNotePage constructor accepts currentUserId
      SettingsPage(/*username: _username, userId: _userId*/), // Pass data to SettingsPage
      // Ensure SettingsPage constructor accepts these
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // You might want to show a loader while user data is being fetched initially
    if (_isUserDataLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Example: Display username in AppBar if MainScreen had its own AppBar
    // This MainScreen itself doesn't have an AppBar, as pages in _getWidgetOptions()
    // are expected to provide their own if needed.
    // However, you could use _username and _userId for other purposes here or pass to an AppBar.
    // For instance, the title of the Scaffold could dynamically change,
    // or you could have a common drawer that uses this info.

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _getWidgetOptions(), // Use the method to get dynamic widget options
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), // Icon for ShoppingNotePage
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Color(0xFFFF8B1E),
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white, // Good to define for fixed type
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}