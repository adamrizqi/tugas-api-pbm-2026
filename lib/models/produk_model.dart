class Product {
  final int id;
  final String name;
  final int price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()).toInt() : 0,
      description: json['description'] ?? '',
    );
  }
}