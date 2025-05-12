import 'package:flutter/material.dart';
import 'package:cookpedia_app/models/food_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodDetail extends StatefulWidget {
  final String idMeal;

  const FoodDetail({super.key, required this.idMeal});

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  late Future<FoodModel> futureFoodDetail;
  String test = '';

  @override
  void initState() {
    super.initState();
    futureFoodDetail = getFoodDetail(widget.idMeal);
  }

  String _splitLine(String instruction) {
    int i = 0;
    String result = "";
    List<String> splitted = instruction.split('\r\n');
    for(String line in splitted){
      i++;
      String num = "Step " + i.toString() + "\n";
      result = result + num + line + "\n\n";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meal Detail")),
      body: FutureBuilder<FoodModel>(
        future: futureFoodDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final food = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(
                          Rect.fromLTRB(0, 330, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.network(food.strMealThumb, fit: BoxFit.cover,),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.strMeal,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        //Row()
                        Text("Category: ${food.strCategory}"),
                        Text("Area: ${food.strArea}"),
                        SizedBox(height: 20),
                        Text("Instructions:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _splitLine(food.strInstructions)

                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<FoodModel> getFoodDetail(String idMeal) async {
    final response = await http.get(
      Uri.parse('https://themealdb.com/api/json/v1/1/lookup.php?i=$idMeal'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];
      if (meals != null && meals.isNotEmpty) {
        return FoodModel.fromJson(meals[0]);
      } else {
        throw Exception("Meal not found");
      }
    } else {
      throw Exception('Failed to load meal');
    }
  }
}
