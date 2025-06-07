import 'package:flutter/material.dart';
import 'package:cookpedia_app/presenter/food_presenter.dart';
import 'package:cookpedia_app/models/food_model.dart';
import 'package:cookpedia_app/models/category_model.dart';
import 'package:cookpedia_app/pages/food_detail_page.dart';
import 'package:cookpedia_app/utils/location_food_service.dart'; // Make sure this path is correct

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> implements FoodView {
  // All your existing state variables and methods remain the same
  late FoodPresenter _presenter;
  bool _isLoading = false;
  List<FoodModel> _foodList = [];
  List<FoodCategoryModel> _foodCategory = [];
  String? _errorMessage;
  String _currentEndpoint = "search.php?s=";

  final LocationFoodService _locationFoodService = LocationFoodService();
  List<FoodModel> _recommendedFoods = [];
  String? _recommendationTitle;
  bool _isLoadingRecommendations = false;
  String? _recommendationError;

  @override
  void initState() {
    super.initState();
    _presenter = FoodPresenter(this);
    _presenter.loadFoodData(_currentEndpoint);
    _fetchCategories();
    _fetchLocalRecommendations();
  }

  void _fetchLocalRecommendations() async {
    // This method remains the same
    setState(() {
      _isLoadingRecommendations = true;
      _recommendationError = null;
      _recommendationTitle = null;
      _recommendedFoods = [];
    });

    try {
      final recommendations = await _locationFoodService.getLocalCuisineRecommendations();
      if(mounted) {
        setState(() {
          _recommendationTitle = recommendations.keys.first;
          _recommendedFoods = recommendations.values.first;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _recommendationError = e.toString();
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  void _fetchData(String searchTerm) {
    // This method remains the same
    setState(() {
      _currentEndpoint = "filter.php?c=$searchTerm";
    });
    _presenter.loadFoodData(_currentEndpoint);
  }

  void _fetchCategories() {
    // This method remains the same
    _presenter.loadFoodCategories();
  }

  Widget _buildRecommendationView() {
    // This method remains the same
    if (_isLoadingRecommendations) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_recommendationError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Error: $_recommendationError", style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _fetchLocalRecommendations, child: const Text("Tap to retry"))
          ],
        ),
      );
    }
    if (_recommendedFoods.isEmpty && _recommendationTitle != null) {
      return const Text("No specific meal recommendations found for your region.");
    }
    if (_recommendedFoods.isEmpty) {
      return const Text("Tap the refresh icon to find dishes from your region!");
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedFoods.length,
        itemBuilder: (context, index) {
          final food = _recommendedFoods[index];
          return Card(
            margin: const EdgeInsets.only(right: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      food.strMealThumb ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.no_food, size: 40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      food.strMeal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==> THE BUILD METHOD IS REFACTORED <==
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF8B1E),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // You can refresh all data here
          _presenter.loadFoodData(_currentEndpoint);
          _fetchCategories();
          _fetchLocalRecommendations();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            if (_isLoadingRecommendations || (_recommendationTitle != null && _recommendedFoods.isNotEmpty))
            // Sliver #1: The Recommendations Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Adjust padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            _recommendationTitle != null
                                ? "Menu Recommendation: $_recommendationTitle"
                                : "Menu Recommendation",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _isLoadingRecommendations ? null : _fetchLocalRecommendations,
                          tooltip: "Get Local Recommendations",
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRecommendationView(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  ),
            ),
            // Sliver #2: The Category Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Give some padding
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _foodCategory.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => _fetchData(category.strCategory),
                          child: Text(category.strCategory),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Conditional Slivers for the Main Food Grid (Loading, Error, or Grid)
            if (_isLoading)
              const SliverFillRemaining( // Takes up the remaining space to show a centered loader
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(child: Text(_errorMessage!)),
              ),

            if (!_isLoading && _errorMessage == null)
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _foodList.length,
                  itemBuilder: (context, index) {
                    final food = _foodList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetail(idMeal: food.idMeal),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  food.strMealThumb,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                        'https://via.placeholder.com/150',
                                        fit: BoxFit.cover
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.strMeal,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    food.strCategory ?? 'No Category', // Safer with null check
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Your FoodView implementation methods (hideLoading, showError, etc.) remain unchanged
  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void showFoodList(List<FoodModel> foodList) {
    setState(() {
      _isLoading = false;
      _foodList = foodList;
      _errorMessage = null;
    });
  }

  @override
  void showFoodCategory(List<FoodCategoryModel> foodCategories) {
    setState(() {
      _foodCategory = foodCategories;
    });
  }
}