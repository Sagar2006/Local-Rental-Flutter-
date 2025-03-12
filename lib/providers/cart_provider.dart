import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  CartService _cartService;

  CartProvider(String userId) : _cartService = CartService(userId) {
    _cartService.addListener(_notifyListeners);
  }

  List<CartItem> get items => _cartService.items;
  int get itemCount => _cartService.itemCount;
  double get totalAmount => _cartService.totalAmount;

  // Add this method to fix the undefined method error
  Future<void> initializeCartForUser(String userId) async {
    // Remove listener from previous cart service
    _cartService.removeListener(_notifyListeners);

    // Create new cart service with new user ID
    _cartService = CartService(userId);
    _cartService.addListener(_notifyListeners);

    // Load cart items for the new user
    await _cartService.loadCartItems();
  }

  Future<void> addItem({
    required String id,
    required String itemId,
    required String name,
    double? hourlyPrice,
    double? dailyPrice,
    required int quantity,
    required String imageUrl,
    required int rentDuration,
    required String priceType,
  }) async {
    final cartItem = CartItem(
      id: id,
      itemId: itemId,
      name: name,
      hourlyPrice: hourlyPrice,
      dailyPrice: dailyPrice,
      quantity: quantity,
      imageUrl: imageUrl,
      rentDuration: rentDuration,
      priceType: priceType,
    );

    await _cartService.addItem(cartItem);
  }

  Future<void> removeItem(String id) async {
    await _cartService.removeItem(id);
  }

  Future<void> updateItemQuantity(String id, int quantity) async {
    await _cartService.updateItemQuantity(id, quantity);
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  @override
  void dispose() {
    _cartService.removeListener(_notifyListeners);
    super.dispose();
  }
}
