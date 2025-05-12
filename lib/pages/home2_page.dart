import 'dart:convert';

import 'package:cookpedia_app/models/food_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cookpedia_app/pages/help_page.dart';
import 'package:cookpedia_app/pages/member_page.dart';
import 'package:cookpedia_app/pages/food_detail_page.dart';
import 'package:cookpedia_app/presenter/food_presenter.dart';
class Home2Page extends StatefulWidget {
  final String username;
  const Home2Page({super.key, required this.username});

  @override
  State<Home2Page> createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> implements FoodView {
  late List<Widget> _pages;
  late FoodPresenter _presenter;
  bool _isLoading = false;
  List<FoodModel> _foodList = [];
  String? _errorMessage;
  String _currentEndpoint = "search.php?s=";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _presenter = FoodPresenter(this);
    _presenter.loadFoodData(_currentEndpoint);
    _pages = [
      HomeBody(),
      MemberPage(),
      HelpPage(),
    ];
  }

  void _fetchData(String endpoint){
    _currentEndpoint = endpoint;
    _presenter.loadFoodData(_currentEndpoint);
  }

  final List<String> _titles = <String>[
    'Home',
    'Member',
    'Help',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titles[_selectedIndex],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.groups), label: 'Member'),
              NavigationDestination(icon: Icon(Icons.help), label: 'Help'),
            ]));
  }

  @override
  void hideLoading() {
    // TODO: implement hideLoading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showError(String message) {
    // TODO: implement showError
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  void showFoodList(List<FoodModel> foodList) {
    // TODO: implement showFoodList
    setState(() {
      _foodList = foodList;
    });
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
    _isLoading = true;
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late FoodPresenter _presenter;
  late Future<List<List<FoodModel>>> futureData;
  bool _isLoading = false;
  int selectedButton = 0;
  List<FoodModel> _foodList = [];
  String? _errorMessage;
  String _currentEndpoint = "search.php?s=a";

  String? id;
  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  void _fetchData(String endpoint){
    _currentEndpoint = endpoint;
    _presenter.loadFoodData(_currentEndpoint);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Anime List"),),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => _fetchData("akatsuki"), child: Text("Akatsuki")),
              SizedBox(width: 10,),
              ElevatedButton(onPressed: () => _fetchData("kara") , child: Text("Kara")),
              SizedBox(width: 10,),
              ElevatedButton(onPressed: () => _fetchData("characters") , child: Text("Characters")),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("Error Message"))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75, // Adjust for image + text
              ),
              itemCount: _foodList.length,
              itemBuilder: (context, index) {
                final food = _foodList[index];
                return GestureDetector(
                  onTap: () {
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Text("expand"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.strMeal, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }

  Widget buildPosts(List<FoodModel> categories, List<FoodModel> foods) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 60, // <<< ini atur tinggi parent ListView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final post = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: selectedButton == index
                            ? Colors.green
                            : Colors.white, // buat height lebih proper
                      ),
                      child: Text(
                        post.strCategory,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          GridView.builder(
            shrinkWrap: true, // ✅ penting agar tidak error di dalam scroll
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              mainAxisSpacing: 8.0, // spacing between rows
              crossAxisSpacing: 8.0, // spacing between columns
            ),
            padding: EdgeInsets.all(8.0), // padding around the grid
            itemCount: foods.length, // total number of items
            itemBuilder: (context, index) {
              final food = foods[index];
              return Container(
                color: Colors.blue, // color of grid items
                child: Center(
                  child: Text(
                    food.strMeal,
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future<List<FoodModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('https://themealdb.com/api/json/v1/1/list.php?c=list'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];

      return (meals as List)
          .map<FoodModel>((json) => FoodModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<FoodModel>> getFoodCategory() async {
    final response = await http.get(
      Uri.parse('https://themealdb.com/api/json/v1/1/search.php?s='),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];

      return (meals as List)
          .map<FoodModel>((json) => FoodModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<List<FoodModel>>> fetchData() async {
    final results = await Future.wait([
      getCategories(),
      getFoodCategory(),
    ]);
    return results;
  }
}
