import 'package:flutter/material.dart';
import 'package:localrental_flutter/pages/home.dart';
<<<<<<< HEAD
// import 'package:localrental_flutter/pages/add_item_page.dart';
// import 'package:localrental_flutter/pages/cart_page.dart';
=======
import 'package:localrental_flutter/pages/add_item_page.dart';
import 'package:localrental_flutter/pages/cart_page.dart';
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return const HomePage();  // Simplified to just return HomePage
=======
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AddItemPage(),
    const CartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Item',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff92A3FD),
        onTap: _onItemTapped,
      ),
    );
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
  }
}
