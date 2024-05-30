import 'package:flutter/material.dart';
import 'package:instacommerce/screens/home_page.dart'; // Replace with your main screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome(); // Navigate after a delay
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2)); // Adjust the delay as needed
    Navigator.pushReplacementNamed(context, '/home'); // Replace '/home' with your actual route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Choose your background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash_screen.jpg'), // Corrected asset path
            SizedBox(height: 20),
            Text(
              'InstaProperty', // Your app name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
