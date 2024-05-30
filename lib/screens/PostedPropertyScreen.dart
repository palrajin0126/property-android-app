import 'dart:convert';
import 'dart:io';
import 'package:instacommerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:instacommerce/models/property_model.dart';
import 'package:image_picker/image_picker.dart';

class PostedPropertiesScreen extends StatefulWidget {
  @override
  _PostedPropertiesScreenState createState() => _PostedPropertiesScreenState();
}

class _PostedPropertiesScreenState extends State<PostedPropertiesScreen> {
  late Future<List<Property>> futureProperties;
  late ImagePicker _imagePicker;

  @override
  void initState() {
    super.initState();
    futureProperties = fetchUserProperties();
    _imagePicker = ImagePicker();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posted Properties'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: FutureBuilder<List<Property>>(
        future: futureProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No properties found.');
          } else {
            List<Property> userProperties = snapshot.data!;
            return ListView.builder(
              itemCount: userProperties.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                    property: userProperties[index], imagePicker: _imagePicker);
              },
            );
          }
        },
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final ImagePicker imagePicker;
  const PropertyCard({
    Key? key,
    required this.property,
    required this.imagePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Property image
          _buildPropertyImage(property),
          // Property details
          ListTile(
            title: Text(property.title),
            subtitle: Text(
                '${property.ownerName} - \Rs ${property.price} - ${property.areaSqft} Sqft'),
          ),
          // Upload Images button
          ElevatedButton(
            onPressed: () {
              _pickImage(property.id!, context);
            },
            child: Text('Upload Images'),
          ),
        ],
      ),
    );
  }

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

  Future<void> _pickImage(int propertyId, BuildContext context) async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        File imageFile = File(pickedFile.path);

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/properties/$propertyId/images/'),
        );

        final secureStorage = FlutterSecureStorage();
        final accessToken = await secureStorage.read(key: 'access_token');

        request.headers['Authorization'] = 'Bearer $accessToken';
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final response = await request.send();

        if (response.statusCode == 201) {
          await _showSuccessDialog(context);
        } else {
          print('Failed to upload image. Status code: ${response.statusCode}');
          print('Response body: ${await response.stream.bytesToString()}');
        }
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Images uploaded successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacementNamed(
                  context, '/home'); // Redirect to homepage
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}