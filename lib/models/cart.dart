import '../models/product.dart';

class Cart {
  final int id;
  final List<Product> products;
  final int totalPrice;
  final DateTime createdAt;

  Cart({
    required this.id,
    required this.products,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int,
      products: (json['products'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
      totalPrice: json['totalPrice'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((product) => product.toJson()).toList(),
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
