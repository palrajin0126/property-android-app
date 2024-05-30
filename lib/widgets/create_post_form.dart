// create_post_form.dart
import 'dart:convert';
import 'dart:io';
import 'package:instacommerce/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:instacommerce/models/property_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreatePostForm extends StatefulWidget {
  @override
  _CreatePostFormState createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _secureStorage = FlutterSecureStorage();
  CustomUser? user; // User details fetched from the backend
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController optionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController propertyTypeController = TextEditingController();
  TextEditingController transactionTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController areaSqftController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController facingDirectionController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  // Add controllers for image and video upload
  TextEditingController imageController = TextEditingController();
  VideoPlayerController? videoController;

  // Other controllers for images and videos can be added as needed

  // Image and Video variables
  // Image and Video variables
  late ImagePicker _imagePicker;
  VideoPlayerController? _videoController;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // Fetch user details when the form is initialized
    getUserDetailsAndInitialize();
    imageController = TextEditingController();
    // Initialize ImagePicker
    _imagePicker = ImagePicker();

    // Initialize VideoPlayerController
    _videoController; // Initialize with an empty file
  }

  Future<void> _pickVideo() async {
    final pickedFile =
    await _imagePicker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoController = VideoPlayerController.file(File(pickedFile.path));
      });
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String accessToken) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/user-details/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user details');
    }
  }

  Future<void> getUserDetailsAndInitialize() async {
    try {
      // Retrieve the access token from Flutter Secure Storage
      String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken != null) {
        // Fetch user details using the access token
        Map<String, dynamic> userData = await fetchUserDetails(accessToken);

        // Use userId when creating the Property object
        // Ensure 'id' is present in the API response
        if (userData.containsKey('id')) {
          print(
              'User details fetched successfully. User ID: ${userData['id']}');
          setState(() {
            user = CustomUser.fromJson(userData);
          });
        } else {
          // Handle the case when 'id' is not present in the API response
          print('User ID not found in the API response.');
        }
      } else {
        // Handle the case when access token is null or not a String
        print('Access token not found or invalid type: $accessToken');
      }
    } catch (error) {
      // Handle the error gracefully
      print('Error fetching user details: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        File imageFile = File(pickedFile.path);

        // Fetch user details and initialize user ID
        await getUserDetailsAndInitialize();

        if (user != null) {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl/users/${user!.id}/images/'),
          );

          // Retrieve the access token from Flutter Secure Storage
          final secureStorage = FlutterSecureStorage();
          final accessToken = await secureStorage.read(key: 'access_token');

          // Include the access token in the request headers
          request.headers['Authorization'] = 'Bearer $accessToken';

          // Use 'image' as the field name
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );

          final response = await request.send();

          if (response.statusCode == 201) {
            print('Image uploaded successfully');
          } else {
            print(
                'Failed to upload image. Status code: ${response.statusCode}');
            print('Response body: ${await response.stream.bytesToString()}');
          }
        } else {
          // Handle the case when user is null
          print('User details are not available.');
        }
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> postProperty(Property property) async {
    final Uri postUrl = Uri.parse('$baseUrl/property/');
    final Map<String, dynamic> propertyJson = property.toJson();

    // Retrieve access token from Flutter Secure Storage
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final String? accessToken = await secureStorage.read(key: 'access_token');

    if (accessToken == null) {
      print('Access token not found. Please authenticate the user.');
      return;
    }

    final response = await http.post(
      postUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken', // Include the access token
      },
      body: jsonEncode(propertyJson),
    );

    if (response.statusCode == 201) {
      print('Property posted successfully');
    } else {
      print('Failed to post property. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Post'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              // Repeat similar TextFormField widgets for other parameters

              // Example for a TextFormField with a numeric input
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: areaController,
                keyboardType:
                TextInputType.number, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'Area',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the area';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cityController,
                keyboardType: TextInputType.text, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'City',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: localityController,
                keyboardType: TextInputType.text, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'Locality',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the locality';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: floorController,
                keyboardType:
                TextInputType.number, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'Floor',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Floor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: contentController,
                keyboardType: TextInputType.text, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'Content',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Content';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: areaSqftController,
                keyboardType:
                TextInputType.number, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'AreaSqft',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Floor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ownerNameController,
                keyboardType: TextInputType.text, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'Owner Name',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Owner Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: contactNumberController,
                keyboardType:
                TextInputType.number, // Set keyboard type to number
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Contact Number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: facingDirectionController.text.isNotEmpty
                    ? facingDirectionController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    facingDirectionController.text = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'north',
                    child: Text('North'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'south',
                    child: Text('South'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'east',
                    child: Text('East'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'west',
                    child: Text('West'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'other',
                    child: Text('Other'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Facing Direction: ',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the facing direction: ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: propertyTypeController.text.isNotEmpty
                    ? propertyTypeController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    propertyTypeController.text = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'house',
                    child: Text('Residential House'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'apartment',
                    child: Text('Apartment'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'society',
                    child: Text('Cooperative Society'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'plot',
                    child: Text('Plot'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'land',
                    child: Text('Land'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'builder_floor',
                    child: Text('Builder Floor'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Property Type: ',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the property type: ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: transactionTypeController.text.isNotEmpty
                    ? transactionTypeController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    transactionTypeController.text = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'lease_hold',
                    child: Text('Lease Hold'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'free_hold',
                    child: Text('Free Hold'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Transaction Type: ',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the transaction type: ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: statusController.text.isNotEmpty
                    ? statusController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    statusController.text = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'ready_to_move',
                    child: Text('Ready to Move'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'under_construction',
                    child: Text('Under Construction'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Status: ',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the status: ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: optionController.text.isNotEmpty
                    ? optionController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    optionController.text = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'sell',
                    child: Text('Sell'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'rent',
                    child: Text('Rent'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Option: ',
                  // Other decoration properties...
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the option: ';
                  }
                  return null;
                },
              ),

              // Add more TextFormField widgets for other parameters

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Fetch user details if not fetched yet
                    await getUserDetailsAndInitialize();

                    if (user != null) {
                      // All input is valid, create a Property object

                      Property newProperty = Property(
                        user: user!, // Ensure user is not null before using it
                        option: optionController.text,
                        title: titleController.text,
                        content: contentController.text,
                        city: cityController.text,
                        area: int.tryParse(areaController.text) ?? 0,
                        locality: localityController.text,
                        floor: int.tryParse(floorController.text) ?? 0,
                        propertyType: propertyTypeController.text,
                        transactionType: transactionTypeController.text,
                        price: double.parse(priceController.text),
                        areaSqft: int.tryParse(areaSqftController.text) ?? 0,
                        ownerName: ownerNameController.text,
                        contactNumber: contactNumberController.text,
                        facingDirection: facingDirectionController.text,
                        status:
                        'ready_to_move', // Set a default status if needed
                        createdAt: DateTime.now(), // Set the current date/time
                        images: [], // Provide an empty list for images
                        videos: [], // Provide an empty list for videos
                      );

                      // Perform the logic to save the new property
                      await postProperty(newProperty);

                      // Close the form
                      Navigator.of(context).pop();
                    } else {
                      // Handle the case when user is still null
                      // For example, show an error message or log a warning
                      print('User details are not available.');
                    }
                  }
                },
                child: Text('Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}