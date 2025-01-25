class CartItem {
  final String id;
  final String itemId;
  final String name;
  final double price;
  final String priceType;
  final int quantity;
  final String imageUrl;
  final int rentDuration;

  CartItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.priceType,
    required this.quantity,
    required this.imageUrl,
    required this.rentDuration,
  });

  double get totalPrice => price * quantity * rentDuration;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'name': name,
      'price': price,
      'priceType': priceType,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'rentDuration': rentDuration,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      itemId: json['itemId'],
      name: json['name'],
      price: json['price'].toDouble(),
      priceType: json['priceType'],
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
      rentDuration: json['rentDuration'],
    );
  }
} 