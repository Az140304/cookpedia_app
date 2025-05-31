class FoodModel {
  final String idMeal;
  final String strMeal;
  final String strDrinkAlternate;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String strTags;
  final String strYoutube;
  final String strSource;
  final String strImageSource;
  final String strCreativeCommonsConfirmed;
  final String dateModified;

  final Map<String, String> ingredients;

  FoodModel({
    required this.idMeal,
    required this.strMeal,
    required this.strDrinkAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.strTags,
    required this.strYoutube,
    required this.strSource,
    required this.strImageSource,
    required this.strCreativeCommonsConfirmed,
    required this.dateModified,
    required this.ingredients,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measures dynamically
    final ingredients = <String, String>{};
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().isNotEmpty &&
          ingredient.toString() != '') {
        ingredients[ingredient] = measure ?? '';
      }
    }

    return FoodModel(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strDrinkAlternate: json['strDrinkAlternate'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      strSource: json['strSource'] ?? '',
      strImageSource: json['strImageSource'] ?? '',
      strCreativeCommonsConfirmed: json['strCreativeCommonsConfirmed'] ?? '',
      dateModified: json['dateModified'] ?? '',
      ingredients: ingredients,

    );
  }
}