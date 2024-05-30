import 'package:flutter/material.dart';
import 'package:instacommerce/services/authentication_service.dart';
import 'package:instacommerce/utils/constants.dart'; // Import the constants file

class LoginScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  LoginScreen({Key? key, required this.navigatorKey}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController loginVerificationCodeController =
  TextEditingController();

  Future<void> _showVerificationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Enter Verification Code'),
            content: TextField(
              controller: loginVerificationCodeController,
              decoration: InputDecoration(labelText: 'Verification Code'),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    final verificationResult = await AuthenticationService(
                      baseUrl: baseUrl, // Use the baseUrl constant here
                    ).verifyLogin(
                      emailController.text,
                      loginVerificationCodeController.text,
                    );

                    print('Verification response: $verificationResult');

                    if (verificationResult.containsKey('message') &&
                        verificationResult['message'] ==
                            'Login verification successful') {
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      print(
                          'Verification failed: ${verificationResult['error']}');
                    }
                  } catch (e) {
                    print('Verification failed: $e');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await AuthenticationService(
                    baseUrl: baseUrl, // Use the baseUrl constant here
                  ).login(
                    emailController.text,
                    passwordController.text,
                  );

                  if (result.containsKey('message') &&
                      result['message'] ==
                          'Verification code sent successfully') {
                    print(
                        'Verification code sent successfully. Showing dialog...');
                    await _showVerificationDialog(context);
                  } else {
                    print('Login failed: ${result['error']}');
                  }
                } catch (e) {
                  print('Login failed: $e');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}