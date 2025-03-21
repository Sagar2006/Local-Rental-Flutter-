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
  bool _isDeletingItem = false;

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
          .map((entry) {
            final itemData = Map<String, dynamic>.from(entry.value);
            itemData['id'] = entry.key; // Ensure ID is set from the key
            return ItemDisplayModel.fromJson(itemData);
          })
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

  Future<void> _deleteItem(String itemId) async {
    setState(() {
      _isDeletingItem = true;
    });

    try {
      // Delete from Firebase
      final databaseRef = FirebaseDatabase.instance.ref();
      await databaseRef.child('items/$itemId').remove();

      // Remove from local list and refresh UI
      setState(() {
        _myItems.removeWhere((item) => item.id == itemId);
        _isDeletingItem = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted successfully'),
          backgroundColor: Color(0xff92A3FD),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isDeletingItem = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting item: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDeleteItem(ItemDisplayModel item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
            'Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteItem(item.id);
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
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _myItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'You haven\'t added any items yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/add_item')
                                  .then((_) => _loadMyItems());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff92A3FD),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
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
                            elevation: 4,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailPage(item: item),
                                  ),
                                ).then((_) => _loadMyItems());
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 150,
                                          child: CachedNetworkImage(
                                            imageUrl: item.featuredImageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                color: const Color(0xff92A3FD)
                                                    .withAlpha(100),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff92A3FD),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '\$${item.price} ${item.priceType == 'per_day' ? '/day' : '/hour'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 18,
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
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Edit button
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ItemDetailPage(
                                                            item: item),
                                                  ),
                                                ).then((_) => _loadMyItems());
                                              },
                                              icon: const Icon(Icons.edit),
                                              label: const Text('Edit'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    const Color(0xff92A3FD),
                                                side: const BorderSide(
                                                    color: Color(0xff92A3FD)),
                                              ),
                                            ),
                                            // Delete button
                                            OutlinedButton.icon(
                                              onPressed: () =>
                                                  _confirmDeleteItem(item),
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: BorderSide(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

          // Overlay loading indicator when deleting an item
          if (_isDeletingItem)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff92A3FD),
        icon: const Icon(Icons.add),
        label: const Text('Add New Item'),
        onPressed: () {
          Navigator.pushNamed(context, '/add_item').then((_) => _loadMyItems());
        },
      ),
    );
  }
}
