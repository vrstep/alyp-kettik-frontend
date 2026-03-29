import 'dart:convert';

class Product {
  final int id;
  final String name;
  final double price;
  final int qty;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.qty = 1,
    required this.createdAt,
  });

  // Convert a Product into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': qty,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Product from a Map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'] is num 
          ? (json['price'] as num).toDouble() 
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      qty: json['quantity'],
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
