import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';
import 'package:localrental_flutter/pages/home.dart';
import 'package:localrental_flutter/pages/add_item_page.dart';
import 'package:localrental_flutter/pages/cart_page.dart';
import 'package:localrental_flutter/pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomePage(),
    const AddItemPage(),
    const CartPage(isInMainNavigation: true),
    const ProfilePage(), // Updated to include ProfilePage
  ];

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _refreshCartIfNeeded(index);
  }

  @override
  Widget build(BuildContext context) {
    // Provide the navigation state to allow other widgets to navigate
    return Provider.value(
      value: this,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });

              _refreshCartIfNeeded(index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xff92A3FD),
            unselectedItemColor: Colors.grey,
            items: const [
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
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to refresh cart data if needed
  void _refreshCartIfNeeded(int index) {
    // Always refresh when switching to cart tab (index 2)
    if (index == 2) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.refreshCart();
    }
  }
}
