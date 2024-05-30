import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:instacommerce/screens/PostedPropertyScreen.dart';
import 'package:instacommerce/screens/DeletePropertiesScreen.dart';
import 'package:instacommerce/services/authentication_service.dart';
import 'package:instacommerce/utils/constants.dart';
import 'package:instacommerce/widgets/login.dart';
import 'package:instacommerce/widgets/signup.dart';
import 'home_page.dart'; // Import your home page file

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _secureStorage = FlutterSecureStorage();
  final AuthenticationService authService =
  AuthenticationService(baseUrl: baseUrl);
  late Future<bool> isAuthenticated;

  @override
  void initState() {
    super.initState();
    isAuthenticated = checkAuthenticationStatus();
  }

  Future<bool> checkAuthenticationStatus() async {
    try {
      final _secureStorage = FlutterSecureStorage();
      String accessToken = await _secureStorage.read(key: 'access_token') ?? '';
      String refreshToken =
          await _secureStorage.read(key: 'refresh_token') ?? '';

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/accounts/check-auth/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['authenticated'] ?? false;
      } else if (response.statusCode == 401) {
        // Token is not valid or expired, log out the user
        await authService.logout(refreshToken);
        return false;
      } else {
        print(
            'Failed to fetch authentication status. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error fetching authentication status: $e');
      return false;
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
          title: Text('Profile'),
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Implement logic for "Accounts" button
                // Fetch user details and show them in a card
                String accessToken =
                    await _secureStorage.read(key: 'access_token') ?? '';
                fetchUserDetails(accessToken).then((userDetails) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('User Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Email: ${userDetails['email']}'),
                            Text('First Name: ${userDetails['first_name']}'),
                            // Add more user details as needed
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: Icon(Icons.account_circle),
            ),
          ],
        ),
        body: FutureBuilder<bool>(
          future: isAuthenticated,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data == true) {
                // User is authenticated, show posted properties and delete button
                return Card(
                  elevation: 5.0,
                  margin: EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostedPropertiesScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Posted Properties',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DeletePropertiesScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Delete Posted Properties',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // User is not authenticated, show login and signup buttons
                return Card(
                  elevation: 5.0,
                  margin: EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Human-shaped widget with a '+' button for image upload only for authenticated users
                        SizedBox(height: 16.0),
                        // Full-width buttons for login and signup
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the Login page
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the Signup page
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the Home page
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Icon(Icons.home),
        ),
      ),
    );
  }
}