import 'package:cookpedia_app/models/food_model.dart';
import 'package:cookpedia_app/models/category_model.dart';
import 'package:cookpedia_app/network/base_network.dart';

abstract class FoodView {
  void showLoading();
  void hideLoading();
  void showFoodList(List<FoodModel> foodList);
  void showFoodCategory(List<FoodCategoryModel> foodCategories);
  void showError(String message);
}

class FoodPresenter {
  final FoodView view;
  FoodPresenter(this.view);

  Future<void> loadFoodData(String endpoint) async {
    try {
      final List<dynamic> data = await BaseNetwork.getData(endpoint);
      final foodList = data.map((json)=> FoodModel.fromJson(json)).toList();
      view.showFoodList(foodList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

  Future<void> loadFoodCategories() async {
    try {
      final List<dynamic> data = await BaseNetwork.getData("list.php?c=list");
      final categoryList = data.map((json) => FoodCategoryModel.fromJson(json)).toList();
      view.showFoodCategory(categoryList);
    } catch (e) {
      view.showError(e.toString());
    }
  }
}