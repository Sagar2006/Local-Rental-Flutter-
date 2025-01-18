class ItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String priceType; // "per_hour" or "per_day"
  final List<String> tags;
  final String userId;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceType,
    required this.tags,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'priceType': priceType,
      'tags': tags,
      'userId': userId,
    };
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      priceType: json['priceType'],
      tags: List<String>.from(json['tags']),
      userId: json['userId'],
    );
  }
}
