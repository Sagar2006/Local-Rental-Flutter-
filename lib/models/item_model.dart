class ItemModel {
  final String id;
  final String name;
  final String description;
  final double? hourlyPrice;
  final double? dailyPrice;
  final List<String> tags;
  final String userId;
  final int quantity;
  final List<String> mediaUrls; // For both images and videos
  final List<bool> isVideo; // Indicates if each mediaUrl is a video
  final String featuredImageUrl;
  final List<String> categories;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    this.hourlyPrice,
    this.dailyPrice,
    required this.tags,
    required this.userId,
    required this.quantity,
    required this.mediaUrls,
    required this.isVideo,
    required this.featuredImageUrl,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'hourlyPrice': hourlyPrice,
        'dailyPrice': dailyPrice,
        'tags': tags,
        'userId': userId,
        'quantity': quantity,
        'mediaUrls': mediaUrls,
        'isVideo': isVideo,
        'featuredImageUrl': featuredImageUrl,
        'categories': categories,
      };

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      hourlyPrice: json['hourlyPrice']?.toDouble(),
      dailyPrice: json['dailyPrice']?.toDouble(),
      tags: List<String>.from(json['tags']),
      userId: json['userId'],
      quantity: json['quantity'],
      mediaUrls: List<String>.from(json['mediaUrls']),
      isVideo: List<bool>.from(json['isVideo']),
      featuredImageUrl: json['featuredImageUrl'],
      categories: List<String>.from(json['categories']),
    );
  }
}
