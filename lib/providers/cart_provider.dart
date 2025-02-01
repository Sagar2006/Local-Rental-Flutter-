import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void initializeCart() {
    final user = _auth.currentUser;
    if (user == null) return;

    _database.child('carts/${user.uid}/items').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _items = data.map((key, value) => MapEntry(
              key,
              CartItem.fromJson(Map<String, dynamic>.from(value)),
            ));
      } else {
        _items = {};
      }
      notifyListeners();
    });
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
    final user = _auth.currentUser;
    if (user == null) return;

    final newItemRef = _database.child('carts/${user.uid}/items').push();
    final cartItem = CartItem(
      id: newItemRef.key!,
      itemId: itemId,
      name: name,
      hourlyPrice: hourlyPrice,
      dailyPrice: dailyPrice,
      quantity: quantity,
      imageUrl: imageUrl,
      rentDuration: rentDuration,
      priceType: priceType,
    );

    await newItemRef.set(cartItem.toJson());
    _items[cartItem.id] = cartItem;
    notifyListeners();
  }

  Future<void> removeItem(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _database.child('carts/${user.uid}/items/$itemId').remove();
    _items.remove(itemId);
    notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_items.containsKey(itemId)) {
      if (quantity <= 0) {
        await removeItem(itemId);
      } else {
        final updatedItem = _items[itemId]!.copyWith(quantity: quantity);
        await _database
            .child('carts/${user.uid}/items/$itemId')
            .update(updatedItem.toJson());
        _items[itemId] = updatedItem;
        notifyListeners();
      }
    }
  }

  Future<void> clear() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _database.child('carts/${user.uid}/items').remove();
    _items.clear();
    notifyListeners();
  }

  void initializeCartForUser() {
    _items.clear();
    initializeCart();
  }
}
