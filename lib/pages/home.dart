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
import 'package:firebase_auth/firebase_auth.dart';

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
  final List<ItemDisplayModel> _trendingItems = [];
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
    _fetchTrendingItems(); // Fetch trending items on initialization
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
            final itemData = Map<String, dynamic>.from(value);
            items.add(ItemDisplayModel.fromJson(
              itemData,
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

  void _fetchTrendingItems() async {
    try {
      final databaseRef = FirebaseDatabase.instance.ref();
      final snapshot = await databaseRef.child('items').get();

      if (!snapshot.exists) {
        setState(() {
          _trendingItems.clear();
        });
        return;
      }

      final items = <ItemDisplayModel>[];
      final data = snapshot.value as Map<dynamic, dynamic>;

      // Fetch random or most cart-added items
      data.forEach((key, value) {
        final itemData = Map<String, dynamic>.from(value);
        if (itemData['cartCount'] != null && itemData['cartCount'] > 5) {
          items.add(ItemDisplayModel.fromJson(itemData));
        }
      });

      setState(() {
        _trendingItems.clear();
        _trendingItems.addAll(items.take(10)); // Limit to 10 items
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading trending items: $e';
      });
    }
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
        final itemData = Map<String, dynamic>.from(value);
        items.add(ItemDisplayModel.fromJson(
          itemData,
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

    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    // Filter out items added by the current user
    final filteredItems = _items.where((item) {
      return item.userId != currentUser?.uid &&
          (_selectedCategory == null ||
              _selectedCategory == 'All' ||
              item.categories.contains(_selectedCategory));
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          _selectedCategory != null
              ? 'No items available in $_selectedCategory category'
              : 'No items available',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Available Items',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
              final isSelected = false; // No selection logic for items
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ItemDetailPage(item: filteredItems[index]),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2D2D2D) // Dark mode color
                        : filteredItems[index]
                            .boxColor
                            .withAlpha(77), // Match category tiles opacity
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.transparent
                          : filteredItems[index].boxColor.withOpacity(0.5),
                      width: 1,
                    ),
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
                              color: Colors.grey.withAlpha(20),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: filteredItems[index]
                                  .featuredImageUrl
                                  .isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      filteredItems[index].featuredImageUrl,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${filteredItems[index].price} ${filteredItems[index].priceType == 'per_day' ? '/day' : '/hour'}',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark
                                  ? Colors
                                      .white // Ensure visibility in dark mode
                                  : filteredItems[index]
                                      .boxColor, // Vibrant in light mode
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
                              filteredItems[index].boxColor.withAlpha(77),
                              filteredItems[index].boxColor.withAlpha(77),
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

  Widget _trendingSection() {
    if (_trendingItems.isEmpty) {
      return const SizedBox(); // Return empty if no trending items
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Trending Items',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 150, // Adjust height for rectangular tiles
          child: ListView.separated(
            itemCount: _trendingItems.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ItemDetailPage(item: _trendingItems[index]),
                    ),
                  );
                },
                child: Container(
                  width: 300, // Wider for rectangular tiles
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2D2D2D)
                        : _trendingItems[index]
                            .boxColor
                            .withAlpha(77), // Match category tiles opacity
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(20),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: _trendingItems[index]
                                  .featuredImageUrl
                                  .isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      _trendingItems[index].featuredImageUrl,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _trendingItems[index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${_trendingItems[index].price} ${_trendingItems[index].priceType == 'per_day' ? '/day' : '/hour'}',
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : _trendingItems[index].boxColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _trendingItems[index].tags.isNotEmpty
                                    ? _trendingItems[index].tags.join(', ')
                                    : 'No tags available',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withAlpha(20)
                : const Color(0xff1D1617).withAlpha(11),
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
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Search items',
            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
            prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      ),
    );
  }

  Widget _categoriesSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Category',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
                    _selectedCategory =
                        isSelected ? null : categories[index].name;
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
                          color: isSelected
                              ? Colors.white.withAlpha(204)
                              : Colors.white,
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
                          color: isSelected
                              ? Colors.white
                              : categories[index].color,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Local Rental',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        foregroundColor: theme.textTheme.bodyLarge?.color,
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
                    MaterialPageRoute(
                        builder: (context) => const AuthWrapper()),
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
      body: Column(
        children: [
          _searchField(),
          const SizedBox(height: 40),
          _categoriesSection(),
          const SizedBox(height: 40),
          _dietSection(),
          const SizedBox(height: 40),
          _trendingSection(), // Add trending section here
        ],
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  final String title;
  final String svgAsset;
  final VoidCallback onTap;
  final Color boxColor; // Add this parameter definition

  const CategoryBox({
    Key? key,
    required this.title,
    required this.svgAsset,
    required this.onTap,
    this.boxColor = Colors.white, // Provide a default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(1.0), // Use withOpacity instead of withAlpha
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(svgAsset),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: boxColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
