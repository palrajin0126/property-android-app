import 'package:flutter/material.dart';
import 'package:instacommerce/widgets/property_card.dart';
import 'package:instacommerce/widgets/search_bar.dart' as MySearchBar;
import 'package:instacommerce/widgets/create_post_form.dart';
import 'package:instacommerce/models/property_model.dart';
import 'package:instacommerce/services/property_service.dart';
import 'package:instacommerce/pages/property_details.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  HomePage({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Property? selectedProperty;
  int _selectedIndex = 0;
  late Future<List<Property>> futureProperties;

  @override
  void initState() {
    super.initState();
    futureProperties = PropertyService.fetchProperties();
  }

  void showPropertyDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(property: property),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add your logic for each tab
    if (_selectedIndex == 0) {
      // Navigate to Home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else if (_selectedIndex == 1) {
      // Navigate to Profile screen
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (_selectedIndex == 2) {
      // Navigate to Search Properties screen
      Navigator.pushReplacementNamed(context, '/search_properties');
    }
  }

  Future<bool> _onWillPop() async {
    // Returning false to block back button
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Logic to handle back navigation
        _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('InstaProperty'),
          automaticallyImplyLeading: false, // Remove back button
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            MySearchBar.SearchBar(
              controller: TextEditingController(),
              onSubmitted: (value) {},
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        FutureBuilder<List<Property>>(
                          future: futureProperties,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No properties available.');
                            } else {
                              List<Property> properties = snapshot.data!;
                              return Column(
                                children: properties.map((property) {
                                  return PropertyCard(
                                    property: property,
                                    onViewDetailsPressed: () {
                                      showPropertyDetails(property);
                                    },
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CreatePostForm();
              },
            );
          },
          child: Icon(Icons.post_add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Filter Properties',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
