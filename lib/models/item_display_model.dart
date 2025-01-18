import 'package:flutter/material.dart';

class ItemDisplayModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String priceType;
  final List<String> tags;
  final String userId;
  final Color boxColor;
  bool viewIsSelected;

  ItemDisplayModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceType,
    required this.tags,
    required this.userId,
    required this.boxColor,
    this.viewIsSelected = false,
  });

  factory ItemDisplayModel.fromJson(Map<String, dynamic> json,
      {Color? boxColor}) {
    return ItemDisplayModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      priceType: json['priceType'] ?? 'per_day',
      tags: List<String>.from(json['tags'] ?? []),
      userId: json['userId'] ?? '',
      boxColor: boxColor ?? const Color(0xff9DCEFF),
      viewIsSelected: false,
    );
  }
}
