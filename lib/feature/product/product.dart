class Product {
  final int id;
  final String name;
  final int price;
  final int quantity;
  final String cover;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.cover,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseToInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: _parseToInt(json['price']),
      quantity: _parseToInt(json['quantity']),
      cover: json['cover']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'cover': cover,
    };
  }

  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
