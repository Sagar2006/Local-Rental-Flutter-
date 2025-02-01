import 'package:flutter/foundation.dart';
import 'package:localrental_flutter/models/cart_item.dart';
import 'package:localrental_flutter/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void initializeCart() {
    _cartService.getCartItems().listen((cartItems) {
      _items = cartItems;
      notifyListeners();
    });
  }

  // Generate a Firebase-safe unique ID
  String _generateCartItemId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> addItem({
    required String itemId,
    required String name,
    double? hourlyPrice,
    double? dailyPrice,
    required String imageUrl,
    required int quantity,
    required int rentDuration,
    required String priceType,
  }) async {
    try {
      final cartItem = CartItem(
        id: _generateCartItemId(),
        itemId: itemId,
        name: name,
        hourlyPrice: hourlyPrice,
        dailyPrice: dailyPrice,
        quantity: quantity,
        imageUrl: imageUrl,
        rentDuration: rentDuration,
        priceType: priceType,
      );

      await _cartService.addToCart(cartItem);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await _cartService.removeFromCart(itemId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      if (_items.containsKey(itemId)) {
        if (quantity <= 0) {
          await removeItem(itemId);
        } else {
          final updatedItem = CartItem(
            id: _items[itemId]!.id,
            itemId: _items[itemId]!.itemId,
            name: _items[itemId]!.name,
            hourlyPrice: _items[itemId]!.hourlyPrice,
            dailyPrice: _items[itemId]!.dailyPrice,
            quantity: quantity,
            imageUrl: _items[itemId]!.imageUrl,
            rentDuration: _items[itemId]!.rentDuration,
            priceType: _items[itemId]!.priceType,
          );
          await _cartService.updateCartItem(updatedItem);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      await _cartService.clearCart();
    } catch (e) {
      rethrow;
    }
  }

  void initializeCartForUser() {
    _items.clear();
    initializeCart();
  }
}
