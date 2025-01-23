import 'package:flutter/material.dart';
import 'package:localrental_flutter/pages/home.dart';
// import 'package:localrental_flutter/pages/add_item_page.dart';
// import 'package:localrental_flutter/pages/cart_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  Widget build(BuildContext context) {
    return const HomePage();  // Simplified to just return HomePage
  }
}
