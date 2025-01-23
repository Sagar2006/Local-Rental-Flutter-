//home.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:localrental_flutter/pages/item_detail_page.dart'; // Import for navigation
// import 'package:localrental_flutter/models/category_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:localrental_flutter/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// import 'package:localrental_flutter/pages/add_item_page.dart';
// import 'package:localrental_flutter/pages/cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class CategoryItem {
  final String name;
  final String iconPath;
  final Color color;

  CategoryItem({
    required this.name,
    required this.iconPath,
    required this.color,
  });
}

class _HomePageState extends State<HomePage> {
  final List<ItemDisplayModel> _items = [];
  bool _isLoading = true;
  String _error = '';
  final List<Color> _alternatingColors = [
    const Color(0xff9DCEFF),
    const Color(0xffEEA4CE),
  ];

  final List<CategoryItem> categories = [
    CategoryItem(
      name: 'Electronics',
      iconPath: 'assets/category_icons/electronics.svg',
      color: const Color(0xff9DCEFF),
    ),
    CategoryItem(
      name: 'Beauty',
      iconPath: 'assets/category_icons/beauty.svg',
      color: const Color(0xffEEA4CE),
    ),
    CategoryItem(
      name: 'Cooking',
      iconPath: 'assets/category_icons/pancakes.svg',
      color: const Color(0xff92A3FD),
    ),
    CategoryItem(
      name: 'Fitness',
      iconPath: 'assets/category_icons/fitness.svg',
      color: const Color(0xffC58BF2),
    ),
    CategoryItem(
      name: 'Travel',
      iconPath: 'assets/category_icons/travel.svg',
      color: const Color(0xff92A3FD),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final databaseRef = FirebaseDatabase.instance.ref();
      final snapshot = await databaseRef.child('items').get();

      if (snapshot.exists) {
        final items = <ItemDisplayModel>[];
        int colorIndex = 0;

        for (var child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          items.add(ItemDisplayModel.fromJson(
            Map<String, dynamic>.from(data),
            boxColor: _alternatingColors[colorIndex % 2],
          ));
          colorIndex++;
        }

        setState(() {
          _items.clear();
          _items.addAll(items);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading items: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _dietSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
          child: Text(_error, style: const TextStyle(color: Colors.red)));
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No items available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Available Items',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 240,
          child: ListView.separated(
            itemCount: _items.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to ItemDetailPage and pass the item data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ItemDetailPage(item: _items[index]),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: _items[index].boxColor.withValues(alpha: 77),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory,
                          size: 50,
                          color: Colors.black54,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _items[index].name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _items[index].description,
                            style: const TextStyle(
                              color: Color(0xff7B6F72),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_items[index].price} ${_items[index].priceType == 'per_day' ? '/day' : '/hour'}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 45,
                        width: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _items[index].boxColor.withValues(alpha: 77),
                              _items[index].boxColor.withValues(alpha: 77),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            _items[index].tags.isNotEmpty
                                ? _items[index].tags[0]
                                : 'View',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withValues(alpha: 0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Search items',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Category',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                decoration: BoxDecoration(
                  color: categories[index].color.withValues(alpha: 77),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(categories[index].iconPath),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index].name,
                      style: TextStyle(
                        color: categories[index].color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // IconData _getCategoryIcon(String category) {
  //   switch (category) {
  //     case 'Electronics':
  //       return Icons.devices;
  //     case 'Beauty':
  //       return Icons.face;
  //     case 'Cooking':
  //       return Icons.restaurant;
  //     case 'Fitness':
  //       return Icons.fitness_center;
  //     case 'Travel':
  //       return Icons.flight;
  //     default:
  //       return Icons.category;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: const Text('Local Rental'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'signout') {
                    try {
                      await context.read<FitnessAuthProvider>().signOut();
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'signout',
                    child: Text('Sign Out'),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                _searchField(),
                const SizedBox(height: 40),
                _categoriesSection(),
                const SizedBox(height: 40),
                _dietSection(),
              ],
            ),
          ),
        ],
      ),
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
        currentIndex: 0,
        selectedItemColor: const Color(0xff92A3FD),
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/add-item');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/cart');
          }
        },
      ),
    );
  }
}
