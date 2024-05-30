import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instacommerce/models/property_model.dart';
import 'package:instacommerce/utils/constants.dart';

class PropertyService {
  static Future<List<Property>> fetchProperties() async {
    final Uri url = Uri.parse('$baseUrl');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final dynamic responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('results')) {
          // If the response has a 'results' key, extract the list
          final results = responseBody['results'];

          if (results is List) {
            return Property.parsePropertiesList(results);
          } else {
            print('Invalid data format. Expected List for "results".');
            return [];
          }
        } else {
          // Handle the case where the response body lacks 'results'
          print('Invalid response format. Expected "results" key.');
          return [];
        }
      } catch (e) {
        print('Error decoding response: $e');
        return [];
      }
    } else {
      print('Failed to load properties. Status Code: ${response.statusCode}');
      throw Exception('Failed to load properties');
    }
  }
}