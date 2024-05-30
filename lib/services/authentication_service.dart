import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart'; // Ensure this import is present

class AuthenticationService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  AuthenticationService({required this.baseUrl});

  Future<Map<String, dynamic>> signup(
      String email,
      String firstName,
      String lastName,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to sign up. ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to sign up. $e');
    }
  }

  Future<Map<String, dynamic>> verifySignup(
      String email,
      String verificationCode,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/verify-signup/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'verification_code': verificationCode,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to verify signup. ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verify signup. $e');
    }
  }

  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/resend-verification/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to resend verification code. ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to resend verification code. $e');
    }
  }

  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if login verification is required
        if (responseData.containsKey('message') &&
            responseData['message'] == 'verification code sent successfully') {
          // Return a message indicating that verification is required
          return {'message': 'Login verification required'};
        } else {
          return responseData;
        }
      } else {
        throw Exception(
            'Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to log in');
    }
  }

  Future<Map<String, dynamic>> verifyLogin(
      String email,
      String verificationCode,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/verify-login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'verification_code': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Store tokens securely
        await _secureStorage.write(
          key: 'access_token',
          value: responseData['access_token'],
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: responseData['refresh_token'],
        );
        return responseData;
      } else {
        throw Exception('Failed to verify login. ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verify login. $e');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/logout/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        // Successful logout
        final responseData = json.decode(response.body);
        if (responseData.containsKey('message') &&
            responseData['message'] == 'Logout successful') {
          print('Logged out successfully');
        } else {
          // Handle unexpected response
          print('Unexpected response after logout');
        }
      } else {
        // Failed to log out
        throw Exception(
            'Failed to log out. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Logout failed: $e');
      throw e; // Propagate the exception if needed
    }
  }
}