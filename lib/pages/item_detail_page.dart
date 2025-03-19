// item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';
import 'package:localrental_flutter/models/cart_item.dart';

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
  final int _rentDuration = 1;
  bool _isLoading = false;
  final String _selectedFeaturedImage = '';
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
    _checkIfItemInCart();
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
      if (controller == null) return const CircularProgressIndicator();

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
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isLoading = true);
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Create a CartItem properly with all required fields
      final cartItem = CartItem(
        id: '${widget.item.id}_${widget.item.priceType == 'per_day' ? 'day' : 'hour'}_$_quantity', // Create a unique ID
        itemId: widget.item.id,
        name: widget.item.name,
        imageUrl: widget.item.featuredImageUrl,
        dailyPrice:
            widget.item.priceType == 'per_day' ? widget.item.dailyPrice : null,
        hourlyPrice: widget.item.priceType == 'per_hour'
            ? widget.item.hourlyPrice
            : null,
        priceType: widget.item.priceType,
        quantity: _quantity,
        rentDuration: _rentDuration,
      );

      // Add the item to the cart
      await cartProvider.addItem(cartItem);

      // Explicitly refresh the cart data after adding an item
      await cartProvider.refreshCart();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isInCart = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item added to cart successfully!'),
          backgroundColor: const Color(0xff92A3FD),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () => _navigateToCart(context),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Updated method to navigate to cart
  void _navigateToCart(BuildContext context) {
    // Pop back to the first route (likely the MainNavigation)
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Navigate to the cart page
    Navigator.of(context).pushNamed('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.mediaUrls.isNotEmpty)
              FlutterCarousel(
                options: CarouselOptions(
                  height: 300.0,
                  showIndicator: true,
                  slideIndicator: const CircularSlideIndicator(),
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
            // Only show Add to Cart button if not in cart
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 50), // Added more bottom padding
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
                  const SizedBox(height: 50), // Added more bottom padding
                ],
              ),
          ],
        ),
      ),
    );
  }
}
