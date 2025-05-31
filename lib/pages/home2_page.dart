import 'package:flutter/material.dart';
import 'package:cookpedia_app/presenter/food_presenter.dart';
import 'package:cookpedia_app/models/food_model.dart';
import 'package:cookpedia_app/pages/food_detail_page.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> implements FoodView {
  late FoodPresenter _presenter;
  bool _isLoading = false;
  List<FoodModel> _foodList = [];
  List<FoodModel> _foodCategory = [];
  String? _errorMessage;
  String _currentEndpoint = "search.php?s=";

  @override
  void initState() {
    super.initState();
    _presenter = FoodPresenter(this);
    _presenter.loadFoodData(_currentEndpoint);
    _fetchCategories();
  }

  void _fetchData(String searchTerm) {
    setState(() {
      _currentEndpoint = "filter.php?c=$searchTerm";
    });
    _presenter.loadFoodData(_currentEndpoint);
  }

  void _fetchCategories() {
    _presenter.loadFoodCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food List")),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:
            Row(
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
          SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12)
                            ),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                  food.strCategory,
                                  style: TextStyle(fontSize: 12)
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
          )
        ],
      ),
    );
  }

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
  @override
  void showFoodCategory(List<FoodModel> foodCategories) {
    setState(() {
      _foodCategory = foodCategories;
    });
  }
}