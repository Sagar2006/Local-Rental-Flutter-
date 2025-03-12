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
    return (priceType == 'hourly' ? hourlyPrice ?? 0 : dailyPrice ?? 0) *
        quantity *
        rentDuration;
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
      id: json['id'] ?? '',
      itemId: json['itemId'] ?? '',
      name: json['name'] ?? '',
      hourlyPrice: json['hourlyPrice'] is num
          ? (json['hourlyPrice'] as num).toDouble()
          : null,
      dailyPrice: json['dailyPrice'] is num
          ? (json['dailyPrice'] as num).toDouble()
          : null,
      quantity: json['quantity'] is int ? json['quantity'] : 1,
      imageUrl: json['imageUrl'] ?? '',
      rentDuration: json['rentDuration'] is int ? json['rentDuration'] : 1,
      priceType: json['priceType'] ?? 'hourly',
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
