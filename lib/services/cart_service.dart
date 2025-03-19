import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartItem> get items => [..._items];

  CartService() {
    loadCartItems();
  }

  // Get user-specific cart reference
  DatabaseReference _getCartRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    return _database.ref().child('carts').child(user.uid);
  }

  Future<void> loadCartItems() async {
    try {
      // First try to sync with Firebase for the most up-to-date data
      await _syncWithFirebase();

      // If that fails or as a fallback, load from local storage
      if (_items.isEmpty) {
        await _loadFromLocal();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading cart items: $e');
      // Fallback to local storage if Firebase sync fails
      await _loadFromLocal();
      notifyListeners();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');

      if (cartData != null) {
        final cartItemsList = jsonDecode(cartData) as List;
        _items.clear();
        _items.addAll(
            cartItemsList.map((item) => CartItem.fromJson(item)).toList());
      }
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  Future<void> _syncWithFirebase() async {
    try {
      final cartRef = _getCartRef();
      final snapshot = await cartRef.once();

      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> cartData = Map<dynamic, dynamic>.from(
            snapshot.snapshot.value as Map<dynamic, dynamic>);

        _items.clear();
        cartData.forEach((key, value) {
          final item = CartItem.fromJson(Map<String, dynamic>.from(value));
          _items.add(item);
        });

        // Update local storage with the latest data
        _saveToLocal();
      }
    } catch (e) {
      print('Error syncing with Firebase: $e');
    }
  }

  Future<void> addItem(CartItem item) async {
    final existingItemIndex = _items.indexWhere(
        (i) => i.itemId == item.itemId && i.priceType == item.priceType);

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      _items[existingItemIndex] = _items[existingItemIndex].copyWith(
          quantity: _items[existingItemIndex].quantity + item.quantity);
    } else {
      _items.add(item);
    }

    await _saveToFirebase();
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveToFirebase();
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> updateItemQuantity(String id, int quantity) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      await _saveToFirebase();
      await _saveToLocal();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    try {
      await _getCartRef().remove();
    } catch (e) {
      print('Error clearing cart: $e');
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartItemsJson =
        jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items', cartItemsJson);
  }

  Future<void> _saveToFirebase() async {
    final cartRef = _getCartRef();
    final Map<String, dynamic> cartData = {};

    for (final item in _items) {
      cartData[item.id] = item.toJson();
    }

    await cartRef.set(cartData);
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return _items.length;
  }

  // Get cart items as a stream
  Stream<List<CartItem>> getCartItems() {
    return _getCartRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return [];
      }

      return data.entries.map((entry) {
        return CartItem.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
    });
  }
}
