import 'package:flutter/material.dart';

class ItemDisplayModel {
  final String id;
  final String name;
  final String description;
  final double? hourlyPrice;
  final double? dailyPrice;
  final List<String> tags;
  final String userId;
  final Color boxColor;
  final int quantity;
  final List<String> mediaUrls;
  final List<bool> isVideo;
  final String featuredImageUrl;
  final List<String> categories;
  bool viewIsSelected;

  ItemDisplayModel({
    required this.id,
    required this.name,
    required this.description,
    this.hourlyPrice,
    this.dailyPrice,
    required this.tags,
    required this.userId,
    required this.boxColor,
    required this.quantity,
    required this.mediaUrls,
    required this.isVideo,
    required this.featuredImageUrl,
    required this.categories,
    this.viewIsSelected = false,
  });

  double get price => hourlyPrice ?? dailyPrice ?? 0.0;
  String get priceType => hourlyPrice != null ? 'per_hour' : 'per_day';

  factory ItemDisplayModel.fromJson(Map<String, dynamic> json,
      {Color? boxColor}) {
    return ItemDisplayModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      hourlyPrice: json['hourlyPrice']?.toDouble(),
      dailyPrice: json['dailyPrice']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      userId: json['userId'] ?? '',
      boxColor: boxColor ?? const Color(0xff9DCEFF),
      quantity: json['quantity'] ?? 0,
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      isVideo: List<bool>.from(json['isVideo'] ?? []),
      featuredImageUrl: json['featuredImageUrl'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      viewIsSelected: false,
    );
  }
}
