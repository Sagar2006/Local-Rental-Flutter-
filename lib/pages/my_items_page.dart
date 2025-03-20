import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:localrental_flutter/pages/item_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  final List<ItemDisplayModel> _myItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyItems();
  }

  Future<void> _loadMyItems() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final databaseRef = FirebaseDatabase.instance.ref();
    final snapshot = await databaseRef.child('items').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final items = data.entries
          .map((entry) => ItemDisplayModel.fromJson(
                Map<String, dynamic>.from(entry.value),
              ))
          .where((item) => item.userId == currentUser.uid)
          .toList();

      if (mounted) {
        setState(() {
          _myItems.clear();
          _myItems.addAll(items);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myItems.isEmpty
              ? const Center(child: Text('You haven\'t added any items yet'))
              : RefreshIndicator(
                  onRefresh: _loadMyItems,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _myItems.length,
                    itemBuilder: (context, index) {
                      final item = _myItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ItemDetailPage(item: item),
                              ),
                            ).then(
                                (_) => _loadMyItems()); // Refresh after return
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: item.featuredImageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${item.price} ${item.priceType == 'per_day' ? '/day' : '/hour'}',
                                        style: const TextStyle(
                                          color: Color(0xff92A3FD),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xff92A3FD)),
                                onPressed: () {
                                  // Open item for editing
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetailPage(item: item),
                                    ),
                                  ).then((_) =>
                                      _loadMyItems()); // Refresh after return
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff92A3FD),
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to add item page
          Navigator.pushNamed(context, '/add_item').then((_) => _loadMyItems());
        },
      ),
    );
  }
}
