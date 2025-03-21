import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';
import 'package:localrental_flutter/models/cart_item.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:localrental_flutter/pages/item_detail_page.dart';

class CartPage extends StatefulWidget {
  final bool isInMainNavigation;

  const CartPage({super.key, this.isInMainNavigation = false});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshCartData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when dependencies change (like when returning to this screen)
    _refreshCartData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshCartData();
    }
  }

  Future<void> _refreshCartData() async {
    setState(() {
      _isLoading = true;
    });

    // Refresh the cart data
    await context.read<CartProvider>().refreshCart();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCartData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final cartItems = cartProvider.items;

                if (cartItems.isEmpty) {
                  return const Center(
                    child: Text('Your cart is empty'),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return CartItemTile(
                            item: item,
                            onRemove: () => _refreshCartData(),
                            onUpdateQuantity: () => _refreshCartData(),
                          );
                        },
                      ),
                    ),
                    _buildCheckoutSection(context, cartProvider),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCheckoutSection(
      BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff92A3FD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement checkout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff92A3FD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onUpdateQuantity;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final databaseRef = FirebaseDatabase.instance.ref();
        final snapshot = await databaseRef.child('items/${item.itemId}').get();

        if (!snapshot.exists || !context.mounted) return;

        final itemData = snapshot.value as Map<dynamic, dynamic>;
        final itemDisplay = ItemDisplayModel.fromJson(
          Map<String, dynamic>.from(itemData),
        );

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: itemDisplay),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor, // Adapt to theme
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black54
                  : Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'item_image_${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color, // Updated
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Display days and hours
                  Row(
                    children: [
                      if (item.days > 0)
                        Text(
                          'Days: ${item.days}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (item.days > 0 && item.hours > 0)
                        Text(
                          ' | ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (item.hours > 0)
                        Text(
                          'Hours: ${item.hours}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Display price
                  Text(
                    '\$${((item.days > 0 ? (item.dailyPrice ?? 0) * item.days : 0) + (item.hours > 0 ? (item.hourlyPrice ?? 0) * item.hours : 0)) * item.quantity}',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color, // Updated
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<CartProvider>().removeItem(item.id);
                    onRemove(); // Call the callback to refresh cart
                  },
                  color: Colors.red,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () async {
                          if (item.quantity > 1) {
                            await context
                                .read<CartProvider>()
                                .updateQuantity(item.id, item.quantity - 1);
                            onUpdateQuantity(); // Call the callback to refresh cart
                          }
                        },
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () async {
                          await context
                              .read<CartProvider>()
                              .updateQuantity(item.id, item.quantity + 1);
                          onUpdateQuantity(); // Call the callback to refresh cart
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: () {
                    _showDurationEditDialog(context, item);
                  },
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to edit duration
  void _showDurationEditDialog(BuildContext context, CartItem item) {
    int days = item.days;
    int hours = item.hours;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Duration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Days selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Days:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (days > 0) {
                                setState(() => days--);
                              }
                            },
                          ),
                          Text('$days'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() => days++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Hours selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hours:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (hours > 0) {
                                setState(() => hours--);
                              }
                            },
                          ),
                          Text('$hours'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() => hours++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Price preview
                  const SizedBox(height: 16),
                  if (days > 0 && item.dailyPrice != null)
                    Text(
                        'Days cost: \$${(item.dailyPrice! * days).toStringAsFixed(2)}'),
                  if (hours > 0 && item.hourlyPrice != null)
                    Text(
                        'Hours cost: \$${(item.hourlyPrice! * hours).toStringAsFixed(2)}'),
                  if ((days > 0 && item.dailyPrice != null) ||
                      (hours > 0 && item.hourlyPrice != null))
                    Text(
                      'Total: \$${((days > 0 ? item.dailyPrice! * days : 0) + (hours > 0 ? item.hourlyPrice! * hours : 0)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (days == 0 && hours == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least some duration'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Create new item with updated duration
                    final newItem = item.copyWith(days: days, hours: hours);
                    final cartProvider = context.read<CartProvider>();

                    try {
                      // First remove old item
                      await cartProvider.removeItem(item.id);

                      // Add new item with new id that includes updated duration
                      await cartProvider.addItem(newItem.copyWith(
                        id: '${item.itemId}_${days}_${hours}_${item.quantity}',
                      ));

                      // Explicitly refresh the cart to ensure updated data is displayed
                      await cartProvider.refreshCart();

                      // Call the callback to update the UI
                      onUpdateQuantity();

                      if (context.mounted) {
                        Navigator.of(context).pop();

                        // Show confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Duration updated successfully'),
                            backgroundColor: Color(0xff92A3FD),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      // Show error message if something went wrong
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating duration: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
