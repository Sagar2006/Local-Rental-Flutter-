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

  void addItem(CartItem item) {
    _cartService.addItem(item);
  }

  void removeItem(String id) {
    _cartService.removeItem(id);
  }

  void clearCart() {
    // Remove the argument
    _cartService.clearCart();
  }

  void updateQuantity(String id, int quantity) {
    _cartService.updateItemQuantity(id, quantity);
  }

  // Add this method as an alias to updateQuantity for consistency
  void updateItemQuantity(String id, int quantity) {
    _cartService.updateItemQuantity(id, quantity);
  }

  // Add the missing initializeCartForUser method
  void initializeCartForUser(String userId) {
    // Since CartService now handles user IDs internally through Firebase Auth,
    // we just need to reload the cart items
    _cartService.loadCartItems();
  }

  double get totalAmount => _cartService.totalAmount;

  int get itemCount => _cartService.itemCount;

  Stream<List<CartItem>> getCartItems() => _cartService.getCartItems();
}
