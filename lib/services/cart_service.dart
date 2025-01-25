import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class CartService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userCartPath {
    final user = _auth.currentUser;
    if (user == null) return null;
    return 'carts/${user.uid}/items';
  }

  Future<void> addToCart(CartItem item) async {
    final cartPath = _userCartPath;
    if (cartPath == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _database.child(cartPath).child(item.id).set(item.toJson());
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    final cartPath = _userCartPath;
    if (cartPath == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _database.child(cartPath).child(itemId).remove();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> updateCartItem(CartItem item) async {
    final cartPath = _userCartPath;
    if (cartPath == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _database.child(cartPath).child(item.id).update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  Stream<Map<String, CartItem>> getCartItems() {
    final cartPath = _userCartPath;
    if (cartPath == null) {
      return Stream.value({});
    }

    return _database.child(cartPath).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};

      return data.map((key, value) => MapEntry(
        key.toString(),
        CartItem.fromJson(Map<String, dynamic>.from(value)),
      ));
    });
  }

  Future<void> clearCart() async {
    final cartPath = _userCartPath;
    if (cartPath == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _database.child(cartPath).remove();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}