import 'dart:convert';
import 'package:instacommerce/models/property_model.dart';
import 'package:instacommerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:instacommerce/screens/FilteredPropertyScreen.dart'; // Import the new screen

class SearchPropertiesScreen extends StatefulWidget {
  @override
  _SearchPropertiesScreenState createState() => _SearchPropertiesScreenState();
}

class _SearchPropertiesScreenState extends State<SearchPropertiesScreen> {
  String city = '';
  String locality = '';
  String selectedPropertyType = 'apartment';
  String selectedOption = 'rent';

  List<String> propertyTypes = [
    'house',
    'apartment',
    'society',
    'plot',
    'builder_floor',
  ];

  List<String> option = [
    'sell',
    'rent',
  ];

  List<Property> filteredProperties = [];

  Future<void> _submitFilter() async {
    // Implement your logic to filter properties based on the selected criteria
    print('Filtering...');
    print('City: $city');
    print('Locality: $locality');
    print('Property Type: $selectedPropertyType');
    print('Option: $selectedOption');

    // Prepare the filter parameters
    Map<String, dynamic> filters = {
      'city': city,
      'locality': locality,
      'property_type': selectedPropertyType, // Keep it as lowercase
      'option': selectedOption,
    };

    // Remove empty values from the query string
    String queryString = filters.entries
        .where((entry) => entry.value != null && entry.value != '')
        .map((entry) =>
    '${entry.key}=${Uri.encodeComponent(entry.value.trim())}')
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
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('results')) {
          List<dynamic> propertiesJson = responseData['results'];
          filteredProperties = propertiesJson
              .map((propertyJson) => Property.fromJson(propertyJson))
              .toList();

          // Navigate to the FilteredPropertyScreen with filtered properties
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Handle back navigation by navigating to home page
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Filter Properties'),
          automaticallyImplyLeading: false, // Remove back button
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    city = value;
                  });
                },
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    locality = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Locality'),
              ),
              DropdownButtonFormField<String>(
                value: selectedPropertyType,
                onChanged: (value) {
                  setState(() {
                    selectedPropertyType = value!;
                  });
                },
                items: propertyTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Property Type'),
              ),
              DropdownButtonFormField<String>(
                value: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
                items: option.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Option'),
              ),
              ElevatedButton(
                onPressed: _submitFilter,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}