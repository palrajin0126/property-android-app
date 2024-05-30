import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instacommerce/models/property_model.dart';
import '../pages/property_details.dart'; // Import the PropertyDetailsPage

class FilteredPropertyScreen extends StatelessWidget {
  final List<Property> filteredProperties;

  FilteredPropertyScreen(this.filteredProperties);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Properties'),
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filtered Properties:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display filtered properties using ListView.builder
            Expanded(
              child: ListView.builder(
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  Property property = filteredProperties[index];
                  // Use the provided Card structure to display property details
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: _buildPropertyImage(property),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Area Sqft: ${property.areaSqft}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Owner: ${property.ownerName}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Owner: ${property.option}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Price: Rs ${property.price.toString()}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Redirect to PropertyDetailsPage
                                  showPropertyDetails(context, property);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                                ),
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

  void showPropertyDetails(BuildContext context, Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(property: property),
      ),
    );
  }
}