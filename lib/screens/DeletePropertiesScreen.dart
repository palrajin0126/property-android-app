import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:instacommerce/utils/constants.dart';
import 'package:instacommerce/models/property_model.dart';

class DeletePropertiesScreen extends StatefulWidget {
  @override
  _DeletePropertiesScreenState createState() => _DeletePropertiesScreenState();
}

class _DeletePropertiesScreenState extends State<DeletePropertiesScreen> {
  late Future<List<Property>> futureProperties;

  @override
  void initState() {
    super.initState();
    futureProperties = fetchUserProperties();
  }

  Future<List<Property>> fetchUserProperties() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final accessToken = await secureStorage.read(key: 'access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/properties'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return Property.parseUserProperties(response.body);
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      throw Exception('Error fetching user properties: $e');
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/properties/$propertyId/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 204) {
      // Property deleted successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property deleted successfully')),
      );
      setState(() {
        futureProperties = fetchUserProperties();
      });
    } else {
      // Failed to delete property
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete property')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Properties'),
      ),
      body: FutureBuilder<List<Property>>(
        future: futureProperties,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final properties = snapshot.data!;
            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Card(
                  margin: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Property Image
                      _buildPropertyImage(property),
                      // Property details
                      ListTile(
                        title: Text(property.title),
                        subtitle: Text('Owner: ${property.ownerName}'),
                      ),
                      // Delete button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Property'),
                                content: Text('Are you sure you want to delete ${property.title}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Convert the property ID to a String
                                      final propertyIdString = property.id.toString();
                                      deleteProperty(propertyIdString);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  // Function to display property image
  Widget _buildPropertyImage(Property property) {
    if (property.images.isNotEmpty) {
      String imagePath = property.images.first.image;
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          height: 200,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          File(imagePath),
          height: 200,
          fit: BoxFit.cover,
        );
      }
    } else {
      return Container(
        height: 200,
        color: Colors.grey[300],
      );
    }
  }
}