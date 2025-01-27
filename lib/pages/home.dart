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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:localrental_flutter/widgets/auth_wrapper.dart';
import 'dart:async';

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
  bool _isLoading = false;
  String _error = '';
  final List<Color> _alternatingColors = [
    const Color(0xff9DCEFF),
    const Color(0xffEEA4CE),
  ];

  final List<CategoryItem> categories = [
    CategoryItem(
      name: 'All',
      iconPath: 'assets/category_icons/all.svg',
      color: const Color(0xff92A3FD),
    ),
    CategoryItem(
      name: 'Electronics',
      iconPath: 'assets/category_icons/electronics.svg',
      color: const Color(0xff9DCEFF),
    ),
    CategoryItem(
      name: 'Sports',
      iconPath: 'assets/category_icons/sports.svg',
      color: const Color(0xffEEA4CE),
    ),
    CategoryItem(
      name: 'Entertainment',
      iconPath: 'assets/category_icons/entertainment.svg',
      color: const Color(0xff92A3FD),
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

  String? _selectedCategory;
  late StreamSubscription<DatabaseEvent> _itemsSubscription;

  @override
  void initState() {
    super.initState();
    _setupItemsListener();
  }

  void _setupItemsListener() {
    final databaseRef = FirebaseDatabase.instance.ref();
    
    _itemsSubscription = databaseRef.child('items').onValue.listen((event) {
      try {
        final snapshot = event.snapshot;
        
        if (snapshot.value == null) {
          setState(() {
            _items.clear();
            _error = '';
          });
          return;
        }

        if (snapshot.exists) {
          final items = <ItemDisplayModel>[];
          int colorIndex = 0;

          final data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            items.add(ItemDisplayModel.fromJson(
              Map<String, dynamic>.from(value),
              boxColor: _alternatingColors[colorIndex % 2],
            ));
            colorIndex++;
          });

          setState(() {
            _items.clear();
            _items.addAll(items);
            _error = '';
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Error loading items: $e';
        });
      }
    }, onError: (error) {
      setState(() {
        _error = 'Database error: $error';
      });
    });
  }

  @override
  void dispose() {
    _itemsSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
  if (_isLoading) return;
  
  setState(() {
    _isLoading = true;
  });

  try {
    final databaseRef = FirebaseDatabase.instance.ref();
    final snapshot = await databaseRef.child('items').get();
    
    if (!snapshot.exists) {
      setState(() {
        _items.clear();
        _isLoading = false;
      });
      return;
    }

    final items = <ItemDisplayModel>[];
    int colorIndex = 0;
    
    final data = snapshot.value as Map<dynamic, dynamic>;
    data.forEach((key, value) {
      items.add(ItemDisplayModel.fromJson(
        Map<String, dynamic>.from(value),
        boxColor: _alternatingColors[colorIndex % 2],
      ));
      colorIndex++;
    });

    setState(() {
      _items.clear();
      _items.addAll(items);
      _isLoading = false;
    });

  } catch (e) {
    setState(() {
      _error = 'Error loading items: $e';
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

    final filteredItems = _selectedCategory != null && _selectedCategory != 'All'
        ? _items.where((item) => item.categories.contains(_selectedCategory)).toList()
        : _items;

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(_selectedCategory != null
            ? 'No items available in $_selectedCategory category'
            : 'No items available'),
      );
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
            itemCount: filteredItems.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(item: filteredItems[index]),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: filteredItems[index].boxColor.withValues(alpha: 77),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: filteredItems[index].featuredImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: filteredItems[index].featuredImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                            const Icon(
                              Icons.inventory,
                              size: 50,
                              color: Colors.black54,
                            ),
                          )
                              : const Icon(
                            Icons.inventory,
                            size: 50,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            filteredItems[index].name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            filteredItems[index].description,
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
                            '\$${filteredItems[index].price} ${filteredItems[index].priceType == 'per_day' ? '/day' : '/hour'}',
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
                              filteredItems[index].boxColor.withValues(alpha: 77),
                              filteredItems[index].boxColor.withValues(alpha: 77),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            filteredItems[index].tags.isNotEmpty
                                ? filteredItems[index].tags[0]
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
              final isSelected = categories[index].name == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = isSelected ? null : categories[index].name;
                  });
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? categories[index].color
                        : categories[index].color.withAlpha(77),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.white,
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
                          color: isSelected ? Colors.white : categories[index].color,
                          fontWeight: FontWeight.w500,
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
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
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: const Color(0xff92A3FD), // Match app theme color
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
          ),
        ],
      ),
    );
  }
}
