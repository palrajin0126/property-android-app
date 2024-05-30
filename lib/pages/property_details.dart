import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import the carousel_slider package
import 'package:instacommerce/models/property_model.dart';
import 'package:instacommerce/screens/ContactPropertyScreen.dart'; // Import the new screen

class PropertyDetailsPage extends StatelessWidget {
  final Property property;

  PropertyDetailsPage({required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InstaProperty'),
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Slider for images
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
              ),
              items: property.images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _buildImage(image),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Title: ${property.title}',
              style: TextStyle(color: Color.fromARGB(255, 14, 13, 13)),
            ),
            SizedBox(height: 10),
            Text(
              'Category: ${property.propertyType}',
              style: TextStyle(color: Color.fromARGB(255, 14, 13, 13)),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${property.content}',
              style: TextStyle(color: Color.fromARGB(255, 17, 17, 17)),
            ),
            SizedBox(height: 10),
            Text(
              'Option: ${property.option}',
              style: TextStyle(color: Color.fromARGB(255, 17, 17, 17)),
            ),

            SizedBox(height: 10),
            Text(
              'Price: Rs ${property.price.toString()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Area in Sqft: ${property.areaSqft}',
              style: TextStyle(color: Color.fromARGB(255, 17, 17, 17)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (property.id != null) {
                  _showContactDialog(
                      context, property.id!); // Pass non-nullable propertyId
                }
              },
              child: Text('Contact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(PropertyImage image) {
    if (image.image.startsWith('http')) {
      return Image.network(
        image.image,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(image.image),
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  void _showContactDialog(BuildContext context, int propertyId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPropertyScreen(
            propertyId: propertyId), // Pass propertyId to ContactPropertyScreen
      ),
    );
  }
}