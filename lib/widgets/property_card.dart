import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instacommerce/models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onViewDetailsPressed;

  PropertyCard({
    required this.property,
    required this.onViewDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: _buildImageSlider(context),
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
                  'Option: ${property.option}',
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
                  onPressed: onViewDetailsPressed,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
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
  }

  Widget _buildImageSlider(BuildContext context) {
    if (property.images.isNotEmpty) {
      return CarouselSlider(
        items: property.images.map((image) {
          if (image.image.startsWith('http')) {
            return CachedNetworkImage(
              imageUrl: image.image,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
              height: 200,
              fit: BoxFit.cover,
            );
          } else {
            return Image.file(
              File(image.image),
              height: 200,
              fit: BoxFit.cover,
            );
          }
        }).toList(),
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          pauseAutoPlayOnTouch: true,
          enableInfiniteScroll: true,
        ),
      );
    } else {
      return Container(
        height: 200,
        color: Colors.grey[300],
      );
    }
  }
}
