import 'package:flutter/material.dart';
import 'package:instacommerce/splash_screen.dart';
import 'screens/home_page.dart';
import 'widgets/login.dart';
import 'widgets/signup.dart';
import 'screens/profile_page.dart';
import 'screens/SearchPropertiesScreen.dart';


final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'InstaProperty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Start with the splash screen
      routes: {
        '/': (context) => SplashScreen(), // Splash screen
        '/login': (context) => LoginScreen(
          navigatorKey: _navigatorKey,
        ),
        '/signup': (context) => SignupScreen(navigatorKey: _navigatorKey),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => HomePage(navigatorKey: _navigatorKey),
        '/search_properties': (context) =>
            SearchPropertiesScreen(), // New route
      },
    );
  }
}
