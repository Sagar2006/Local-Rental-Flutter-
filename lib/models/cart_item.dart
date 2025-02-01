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
    if (priceType == 'hourly' && hourlyPrice != null) {
      return hourlyPrice! * quantity * rentDuration;
    } else if (priceType == 'daily' && dailyPrice != null) {
      return dailyPrice! * quantity * rentDuration;
    }
    return 0.0;
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
      hourlyPrice: json['hourlyPrice']?.toDouble(),
      dailyPrice: json['dailyPrice']?.toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
      rentDuration: json['rentDuration'],
      priceType: json['priceType'],
    );
  }
}
