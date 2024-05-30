import 'package:instacommerce/widgets/login.dart';
import 'package:flutter/material.dart';
import 'package:instacommerce/services/authentication_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:instacommerce/utils/constants.dart';

class ContactPropertyScreen extends StatefulWidget {
  final int propertyId; // Add propertyId field

  ContactPropertyScreen({required this.propertyId}); // Constructor

  @override
  _ContactPropertyScreenState createState() => _ContactPropertyScreenState();
}

class _ContactPropertyScreenState extends State<ContactPropertyScreen> {
  final AuthenticationService authService =
  AuthenticationService(baseUrl: '$baseUrl');
  final _secureStorage = FlutterSecureStorage();
  late Future<bool> isAuthenticated;

  @override
  void initState() {
    super.initState();
    isAuthenticated = checkAuthenticationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Property'),
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: FutureBuilder<bool>(
          future: isAuthenticated,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.data == true) {
                // User is authenticated, send verification code immediately
                sendVerificationCode();
                return _buildVerificationCodeForm();
              } else {
                // User is not authenticated, show a login button or prompt
                return _buildLoginPrompt();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerificationCodeForm() {
    final TextEditingController verificationCodeController =
    TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Enter the 6-digit verification code sent to your email:'),
        TextFormField(
          controller: verificationCodeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          // Add controller to handle verification code input
        ),
        ElevatedButton(
          onPressed: () {
            // Handle verification code submission
            verifyVerificationCode(verificationCodeController.text,
                widget.propertyId); // Pass propertyId
          },
          child: Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Please login to view contact details.'),
        ElevatedButton(
          onPressed: () {
            // Navigate to the login screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  navigatorKey: GlobalKey<NavigatorState>(),
                ),
              ),
            );
          },
          child: Text('Login'),
        ),
      ],
    );
  }

  Future<bool> checkAuthenticationStatus() async {
    try {
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

  Future<void> sendVerificationCode() async {
    try {
      String accessToken = await _secureStorage.read(key: 'access_token') ?? '';

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/send-verification-code/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Handle success, e.g., show a success message
        print('Verification code sent successfully');
      } else {
        // Handle failure, e.g., show an error message
        print(
            'Failed to send verification code. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending verification code: $e');
    }
  }

  Future<void> verifyVerificationCode(
      String verificationCode, int propertyId) async {
    try {
      String accessToken = await _secureStorage.read(key: 'access_token') ?? '';

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> requestBody = {
        'verification_code': verificationCode,
        'property_id': propertyId.toString(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/verify-verification-code/'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Verification successful, send contact details email
        print("Verification successful. status code: ${response.statusCode}");

        // Display an alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text(
                  "Contact details and property details shared to your email."),
              actions: [
                TextButton(
                  onPressed: () {
                    // Navigate to the home page
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Handle verification failure
        print('Verification failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle verification failure
      print('Error verifying verification code: $e');
    }
  }
}