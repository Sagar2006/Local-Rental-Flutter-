class CartItem {
  final String id;
  final String itemId;
  final String name;
  final String imageUrl;
  final double? dailyPrice;
  final double? hourlyPrice;
  final String priceType;
  final int quantity;
  final int days; // Changed from rentDuration to days
  final int hours; // Added hours field

  CartItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.imageUrl,
    this.dailyPrice,
    this.hourlyPrice,
    required this.priceType,
    required this.quantity,
    required this.days, // Changed parameter name
    required this.hours, // Added parameter
  });

  double get totalPrice {
    double price = 0;
    if (priceType == 'per_day' && dailyPrice != null) {
      price = dailyPrice! * days;
    } else if (priceType == 'per_hour' && hourlyPrice != null) {
      price = hourlyPrice! * hours;
    }
    return price * quantity;
  }

  CartItem copyWith({
    String? id,
    String? itemId,
    String? name,
    String? imageUrl,
    double? dailyPrice,
    double? hourlyPrice,
    String? priceType,
    int? quantity,
    int? days,
    int? hours,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      priceType: priceType ?? this.priceType,
      quantity: quantity ?? this.quantity,
      days: days ?? this.days,
      hours: hours ?? this.hours,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      itemId: json['itemId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      dailyPrice: json['dailyPrice']?.toDouble(),
      hourlyPrice: json['hourlyPrice']?.toDouble(),
      priceType: json['priceType'],
      quantity: json['quantity'],
      days: json['days'] ?? 0,
      hours: json['hours'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'name': name,
      'imageUrl': imageUrl,
      'dailyPrice': dailyPrice,
      'hourlyPrice': hourlyPrice,
      'priceType': priceType,
      'quantity': quantity,
      'days': days,
      'hours': hours,
    };
  }
}
