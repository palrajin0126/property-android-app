import 'package:flutter/material.dart';
import 'package:instacommerce/services/authentication_service.dart';
import 'package:instacommerce/utils/constants.dart';

class SignupScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  SignupScreen({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verificationCodeController =
  TextEditingController();

  Future<void> _showVerificationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: verificationCodeController,
              decoration: InputDecoration(labelText: 'Verification Code'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Verify the signup using the entered code
                    final verificationResult = await AuthenticationService(
                      baseUrl: baseUrl,
                    ).verifySignup(
                      emailController.text,
                      verificationCodeController.text,
                    );

                    print('Verification response: $verificationResult');

                    // Check for successful verification
                    if (verificationResult['message'] ==
                        'Signup verification successful') {
                      // Show success dialog
                      await _showSuccessDialog(context);
                    } else {
                      // Handle verification failure
                      print(
                          'Verification failed: ${verificationResult['message']}');
                    }
                  },
                  child: Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _showResendDialog(context);
                  },
                  child: Text('Resend'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thank you for signing up!'),
        content:
        Text('Now you can login to get contact details or post property.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacementNamed(
                  context, '/login'); // Redirect to login page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResendDialog(BuildContext context) async {
    // Resend verification code logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
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
                    baseUrl: baseUrl,
                  ).signup(
                    emailController.text,
                    firstNameController.text,
                    lastNameController.text,
                    passwordController.text,
                  );

                  print('Signup response: $result');

                  if (result.containsKey('id') && result.containsKey('email')) {
                    await _showVerificationDialog(context);
                  } else {
                    print('Signup failed: ${result['message']}');
                  }
                } catch (e) {
                  print('Operation failed: $e');
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}