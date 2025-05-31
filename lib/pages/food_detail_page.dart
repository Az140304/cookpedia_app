import 'package:flutter/material.dart';
import 'package:cookpedia_app/models/food_model.dart';
import 'package:http/http.dart' as http;
import 'package:cookpedia_app/network/base_network.dart';
import 'dart:convert';

class FoodDetail extends StatefulWidget {
  final String idMeal;

  const FoodDetail({
    super.key,
    required this.idMeal
  });

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  String test = '';
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;
  String? errorMessage;
  Map<String, String> ingredients = {};

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    try {
      final data = await BaseNetwork.getDetailData(widget.idMeal);
      setState(() {
        _detailData = data;
        _isLoading = false;
      });
    } catch (e) {
      errorMessage = e.toString();
      _isLoading = false;
    }
  }


  Widget _buildIngredientsSection() {
    try {
      // Check if data is available
      if (_detailData == null ||
          _detailData!['meals'] == null ||
          _detailData!['meals'].isEmpty) {
        print('No meal data available for ingredients');
        return Text('No ingredients data available',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic));
      }

      // Extract ingredients and measures from the API response
      Map<String, String> ingredients = {};

      // API returns up to 20 possible ingredients
      for (int i = 1; i <= 20; i++) {
        try {
          final ingredient = _detailData!['meals'][0]['strIngredient$i'];
          final measure = _detailData!['meals'][0]['strMeasure$i'];

          if (ingredient != null &&
              ingredient.toString().isNotEmpty &&
              ingredient.toString() != 'null' &&
              ingredient.toString() != '') {
            ingredients[ingredient] = measure ?? '';
          }
        } catch (e) {
          print('Error processing ingredient $i: $e');
          // Continue with next ingredient
        }
      }

      // Check if we found any ingredients
      if (ingredients.isEmpty) {
        return Text('No ingredients found',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic));
      }

      // Return the ingredients list
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ingredients.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    "${entry.value.trim()} ${entry.key.trim()}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } catch (e) {
      print('Error building ingredients section: $e');
      return Text('Error loading ingredients',
          style: TextStyle(fontSize: 16, color: Colors.red));
    }
  }

  String _splitLine(String instruction) {
    int i = 0;
    String result = "";
    List<String> splitted = instruction.split('\r\n');
    for(String line in splitted){
      //i++;
      //String num = "Step " + i.toString() + "\n";
      result = result /*+ num */+ line + "\n\n";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Meal Detail")),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage.toString()))
            : _detailData != null
            ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                child: Image.network(
                  _detailData!['meals'][0]['strMealThumb'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _detailData!['meals'][0]['strMeal'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // You can add more details here like category, area, etc.
                    Text(
                      "Category: ${_detailData!['meals'][0]['strCategory'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Area: ${_detailData!['meals'][0]['strArea'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),


                    Text(
                      "Ingredients:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildIngredientsSection(),
                    SizedBox(height: 16),
                    Text(
                      "Instructions:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _splitLine(_detailData!['meals'][0]['strInstructions'] ?? ''),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            : Center(child: Text("No Data Available"))
    );
  }


}