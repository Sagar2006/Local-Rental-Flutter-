class CartItem {
  final String id;
  final String itemId;
  final String name;
  final double? hourlyPrice;
  final double? dailyPrice;
  final int quantity;
  final String imageUrl;
  final int rentDuration;
  final String priceType;

  CartItem({
    required this.id,
    required this.itemId,
    required this.name,
    this.hourlyPrice,
    this.dailyPrice,
    required this.quantity,
    required this.imageUrl,
    required this.rentDuration,
    required this.priceType,
  });

  double get totalPrice {
    return (hourlyPrice ?? dailyPrice ?? 0) * quantity * rentDuration;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'name': name,
      'hourlyPrice': hourlyPrice,
      'dailyPrice': dailyPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'rentDuration': rentDuration,
      'priceType': priceType,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      itemId: json['itemId'],
      name: json['name'],
      hourlyPrice: json['hourlyPrice'],
      dailyPrice: json['dailyPrice'],
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
      rentDuration: json['rentDuration'],
      priceType: json['priceType'],
    );
  }

  CartItem copyWith({
    String? id,
    String? itemId,
    String? name,
    double? hourlyPrice,
    double? dailyPrice,
    int? quantity,
    String? imageUrl,
    int? rentDuration,
    String? priceType,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      rentDuration: rentDuration ?? this.rentDuration,
      priceType: priceType ?? this.priceType,
    );
  }
}
