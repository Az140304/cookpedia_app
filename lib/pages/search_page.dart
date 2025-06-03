// lib/pages/search_page.dart
import 'dart:async'; // For Timer (debouncing - optional enhancement)
import 'package:flutter/material.dart';
import 'package:cookpedia_app/network/base_network.dart'; // Your BaseNetwork class
import 'package:cookpedia_app/models/food_model.dart';   // Your FoodModel
import 'package:cookpedia_app/pages/food_detail_page.dart'; // Your FoodDetailPage
import 'package:cached_network_image/cached_network_image.dart'; // For better image loading


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<FoodModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchStatusMessage = "Please enter a meal name to search.";
  Timer? _debounce;

  // If you have implemented FoodRepository, it's better to use it here
  // final FoodRepository _foodRepository = FoodRepository();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
            _errorMessage = null;
            _searchStatusMessage = "Please enter a meal name to search.";
          });
        }
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _errorMessage = null;
          _searchStatusMessage = "Please enter a meal name to search.";
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchStatusMessage = ""; // Clear status message during search
    });

    try {
      // Using BaseNetwork directly. If you have a FoodRepository, use that instead.
      // Example: final foodsData = await _foodRepository.searchFoods(query);
      final List<dynamic> foodsData = await BaseNetwork.getData("search.php?s=$query");

      if (mounted) {
        if (foodsData.isEmpty) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
            _searchStatusMessage = "No meals found for \"$query\".";
          });
        } else {
          setState(() {
            _searchResults = foodsData.map((data) => FoodModel.fromJson(data)).toList();
            _isLoading = false;
            _searchStatusMessage = "${_searchResults.length} results for \"$query\".";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load search results: ${e.toString()}";
          _searchResults = [];
          _searchStatusMessage = "Error searching. Please try again.";
        });
      }
      print('Error performing search: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Meals", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFFFF8B1E),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter meal name (e.g., Chicken, Beef)',
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    // _performSearch(''); // Optionally clear results or let debouncer handle it
                  },
                )
                    : null,
              ),
              // No explicit search button; search is triggered by _onSearchChanged (debounced)
              // If you want a button:
              // onSubmitted: (value) => _performSearch(value),
            ),
          ),
          Expanded(
            child: _buildSearchResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_searchStatusMessage, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        ),
      );
    }

    // Display results in a GridView, similar to FoodListScreen
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75, // Adjust for desired item aspect ratio
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return GestureDetector(
          onTap: () {
            if (food.idMeal.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetail(idMeal: food.idMeal),
                ),
              );
            }
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias, // Ensures image respects card's rounded corners
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: food.strMealThumb ?? "",
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/placeholder_food.png', // Add a placeholder image to your assets
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    food.strMeal,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (food.strCategory != null && food.strCategory!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                    child: Text(
                      food.strCategory!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}