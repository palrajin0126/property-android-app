import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:instacommerce/models/property_model.dart';
import '../utils/constants.dart'; // Import the service to make API calls
import '../screens/FilteredPropertyScreen.dart'; // Import the FilteredPropertyScreen

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(List<Property>) onSubmitted; // Modify the callback argument

  const SearchBar({Key? key, required this.controller, required this.onSubmitted}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String city = '';
  String locality = '';
  List<Property> filteredProperties = [];
  Future<void> _onSearchSubmitted(String value) async {
    // Prepare the filter parameters
    Map<String, dynamic> filters = {
      'city': value, // Use the search query for city filtering// Placeholder for locality (optional)
    };

    // Remove empty values from the query string
    String queryString = filters.entries
        .where((entry) => entry.value != null && entry.value != '')
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.trim())}')
        .join('&');

    // Construct the API endpoint URL
    String apiUrl = '$baseUrl/property-filter/?$queryString';

    // Make the HTTP request
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Response: $response');
      if (response.statusCode == 200) {
        // Parse the response JSON and handle the filtered properties
        dynamic responseData = jsonDecode(response.body);

        // Ensure responseData is a Map and has a key 'results'
        if (responseData is Map<String, dynamic> && responseData.containsKey('results')) {
          List<dynamic> propertiesJson = responseData['results'];
          List<Property> filteredProperties = propertiesJson
              .map((propertyJson) => Property.fromJson(propertyJson))
              .toList();

          // Call the onSubmitted callback with filtered properties
          widget.onSubmitted(filteredProperties);

          // Navigate to FilteredPropertyScreen with filtered properties
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredPropertyScreen(filteredProperties),
            ),
          );
        } else {
          print('Invalid response format');
        }
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: widget.controller,
        onSubmitted: _onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Search properties by City...',
        ),
      ),
    );
  }
}