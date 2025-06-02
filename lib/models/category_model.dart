class FoodCategoryModel {
  final String strCategory;

  FoodCategoryModel({required this.strCategory});

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) {
    return FoodCategoryModel(strCategory: json['strCategory']);
  }
}