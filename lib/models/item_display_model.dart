import 'package:flutter/material.dart';

class ItemDisplayModel {
  final String id;
  final String name;
  final String description;
  final double? dailyPrice;
  final double? hourlyPrice;
  final String priceType;
  final List<String> tags;
  final List<String> mediaUrls;
  final List<bool> isVideo;
  final String featuredImageUrl;
  final String userId;
  final int createdAt;
  final int updatedAt;
  final Color boxColor; // Add this property
  final List<String> categories; // Add this property for category filtering

  ItemDisplayModel({
    required this.id,
    required this.name,
    required this.description,
    this.dailyPrice,
    this.hourlyPrice,
    required this.priceType,
    required this.tags,
    required this.mediaUrls,
    required this.isVideo,
    required this.featuredImageUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.boxColor = Colors.blue, // Default color
    this.categories = const [], // Default empty list
  });

  // Calculate the price based on price type
  double get price =>
      priceType == 'per_day' ? (dailyPrice ?? 0.0) : (hourlyPrice ?? 0.0);

  factory ItemDisplayModel.fromJson(Map<String, dynamic> json,
      {Color boxColor = Colors.blue}) {
    return ItemDisplayModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dailyPrice: json['dailyPrice']?.toDouble(),
      hourlyPrice: json['hourlyPrice']?.toDouble(),
      priceType: json['priceType'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      isVideo: List<bool>.from(json['isVideo'] ?? []),
      featuredImageUrl: json['featuredImageUrl'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      updatedAt: json['updatedAt'] ?? json['createdAt'] ?? 0,
      boxColor: boxColor, // Use the provided boxColor
      categories: List<String>.from(
          json['tags'] ?? []), // Use tags as categories for filtering
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dailyPrice': dailyPrice,
      'hourlyPrice': hourlyPrice,
      'priceType': priceType,
      'tags': tags,
      'mediaUrls': mediaUrls,
      'isVideo': isVideo,
      'featuredImageUrl': featuredImageUrl,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'boxColor': boxColor, // Add this property
      'categories': categories, // Add this property
    };
  }
}
