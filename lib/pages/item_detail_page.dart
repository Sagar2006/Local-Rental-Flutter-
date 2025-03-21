// item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';
import 'package:localrental_flutter/models/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localrental_flutter/pages/edit_item_page.dart';

class ItemDetailPage extends StatefulWidget {
  final ItemDisplayModel item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final Map<String, VideoPlayerController> _controllers = {};
  int _currentMediaIndex = 0;
  final int _quantity = 1;
  int _days = 0; // Changed from _rentDuration to _days
  int _hours = 0; // Added _hours
  bool _isLoading = false;
  final String _selectedFeaturedImage = '';
  bool _isInCart = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
    _checkIfItemInCart();
    _checkIfUserIsOwner();
  }

  Future<void> _initializeVideoControllers() async {
    for (int i = 0; i < widget.item.mediaUrls.length; i++) {
      if (widget.item.isVideo[i]) {
        final controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.item.mediaUrls[i]));
        await controller.initialize();
        _controllers[widget.item.mediaUrls[i]] = controller;
      }
    }
    setState(() {});
  }

  void _checkIfItemInCart() {
    final cartProvider = context.read<CartProvider>();
    setState(() {
      _isInCart =
          cartProvider.items.any((item) => item.itemId == widget.item.id);
    });
  }

  void _checkIfUserIsOwner() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && widget.item.userId == currentUser.uid) {
      setState(() {
        _isOwner = true;
      });
    }
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(item: widget.item),
      ),
    );

    if (result == true) {
      final databaseRef = FirebaseDatabase.instance.ref();
      final snapshot = await databaseRef.child('items/${widget.item.id}').get();

      if (!snapshot.exists || !mounted) return;

      final itemData = snapshot.value as Map<dynamic, dynamic>;
      final updatedItem = ItemDisplayModel.fromJson(
        Map<String, dynamic>.from(itemData),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: updatedItem),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaWidget(String url, bool isVideo) {
    if (isVideo) {
      final controller = _controllers[url];
      if (controller == null) {
        // Improved video loading placeholder
        return Container(
          color: Colors.black.withOpacity(0.1),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xff92A3FD),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Loading video...",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            IconButton(
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
            ),
          ],
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xff92A3FD), Color(0xff9DCEFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Color(0xff92A3FD),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isLoading = true);
    try {
      if (_days == 0 && _hours == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a borrowing duration (days or hours)'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final cartItem = CartItem(
        id: '${widget.item.id}_${_days}_${_hours}_$_quantity',
        itemId: widget.item.id,
        name: widget.item.name,
        imageUrl: widget.item.featuredImageUrl,
        dailyPrice: widget.item.dailyPrice,
        hourlyPrice: widget.item.hourlyPrice,
        priceType: widget.item.priceType,
        quantity: _quantity,
        days: _days,
        hours: _hours,
      );

      await cartProvider.addItem(cartItem);

      await cartProvider.refreshCart();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isInCart = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added to cart successfully!'),
          backgroundColor: Color(0xff92A3FD),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToCart(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);

    Navigator.of(context).pushNamed('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = widget.item.userId == currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditPage,
              tooltip: 'Edit Item',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.mediaUrls.isNotEmpty)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      FlutterCarousel(
                        options: CarouselOptions(
                          height: 300.0,
                          showIndicator: false, // Disable default indicators
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentMediaIndex = index;
                              for (final controller in _controllers.values) {
                                controller.pause();
                              }
                            });
                          },
                        ),
                        items: List.generate(
                          widget.item.mediaUrls.length,
                          (index) => _buildMediaWidget(
                            widget.item.mediaUrls[index],
                            widget.item.isVideo[index],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.item.mediaUrls.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentMediaIndex == index ? 12 : 8,
                              height: _currentMediaIndex == index ? 12 : 8,
                              decoration: BoxDecoration(
                                color: _currentMediaIndex == index
                                    ? const Color(0xff92A3FD)
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.item.hourlyPrice != null)
              Text(
                '\$${widget.item.hourlyPrice} /hour',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xff92A3FD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (widget.item.dailyPrice != null)
              Text(
                '\$${widget.item.dailyPrice} /day',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xff92A3FD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Tags:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.item.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xff92A3FD).withAlpha(77),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (!isOwner) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Borrowing Duration:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Days',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
                                onPressed: () {
                                  setState(() {
                                    if (_days > 0) _days--;
                                  });
                                },
                              ),
                              Text(
                                '$_days',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _days++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hours',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
                                onPressed: () {
                                  setState(() {
                                    if (_hours > 0) _hours--;
                                  });
                                },
                              ),
                              Text(
                                '$_hours',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _hours++;
                                  });
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
              const SizedBox(height: 16),
              if (_days > 0 && widget.item.dailyPrice != null)
                Text(
                  'Days cost: \$${(widget.item.dailyPrice! * _days).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xff92A3FD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (_hours > 0 && widget.item.hourlyPrice != null)
                Text(
                  'Hours cost: \$${(widget.item.hourlyPrice! * _hours).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xff92A3FD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if ((_days > 0 && widget.item.dailyPrice != null) ||
                  (_hours > 0 && widget.item.hourlyPrice != null))
                Text(
                  'Total: \$${((_days > 0 ? widget.item.dailyPrice! * _days : 0) + (_hours > 0 ? widget.item.hourlyPrice! * _hours : 0)).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff92A3FD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 24),
              if (!_isInCart)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _addToCart(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff92A3FD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Item Already in Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
