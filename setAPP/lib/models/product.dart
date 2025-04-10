class Product {
  final int productId;
  final String productName;
  final String category;
  final double price;
  final double cost;
  final String? description;
  final bool seasonal;
  final bool active;
  final DateTime introducedDate;
  final String? ingredients;

  Product({
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.cost,
    this.description,
    required this.seasonal,
    required this.active,
    required this.introducedDate,
    this.ingredients,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["ProductId"],
      productName: json["ProductName"],
      category: json["Category"],
      price: (json["Price"] as num).toDouble(),
      cost: (json["Cost"] as num).toDouble(),
      description: json["Description"],
      seasonal: json["Seasonal"] as bool,
      active: json["Active"] as bool,
      introducedDate: DateTime.parse(json["IntroducedDate"]),
      ingredients: json["Ingredients"],
    );
  }
}
