import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;

  CartProvider(this._cartService) {
    // Initialize without arguments
    _cartService.loadCartItems();
  }

  List<CartItem> get items => _cartService.items;

  Future<void> addItem(CartItem item) async {
    await _cartService.addItem(item);
    // Refresh after adding
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    await _cartService.removeItem(id);
    // Refresh after removing
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    // Refresh after clearing
    notifyListeners();
  }

  Future<void> updateQuantity(String id, int quantity) async {
    await _cartService.updateItemQuantity(id, quantity);
    // Refresh after updating quantity
    notifyListeners();
  }

  // Update this method as alias to also return a Future
  Future<void> updateItemQuantity(String id, int quantity) async {
    await _cartService.updateItemQuantity(id, quantity);
    notifyListeners();
  }

  void initializeCartForUser(String userId) {
    // Since CartService now handles user IDs internally through Firebase Auth,
    // we just need to reload the cart items
    _cartService.loadCartItems();
  }

  // Add a method to refresh the cart data
  Future<void> refreshCart() async {
    await _cartService.loadCartItems();
  }

  double get totalAmount => _cartService.totalAmount;

  int get itemCount => _cartService.itemCount;

  Stream<List<CartItem>> getCartItems() => _cartService.getCartItems();
}
