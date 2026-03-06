import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String category;
  final String desc;
  final int price;
  final String imagePath;
  final String barcode;
  final bool isStock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.desc,
    required this.price,
    required this.imagePath,
    this.barcode = "",
    required this.isStock,
    required this.createdAt,
  });

  // Convert a Product into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'desc': desc,
      'price': price,
      'imagePath': imagePath,
      'barcode': barcode,
      'isStock': isStock,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Product from a Map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      desc: json['desc'],
      price: json['price'],
      imagePath: json['imagePath'],
      barcode: json['barcode'] ?? "",
      isStock: json['isStock'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Optional: Helper method to serialize a Product to a JSON string
  String toJsonString() => jsonEncode(toJson());

  // Optional: Helper method to deserialize a Product from a JSON string
  static Product fromJsonString(String jsonString) {
    return Product.fromJson(jsonDecode(jsonString));
  }
}
