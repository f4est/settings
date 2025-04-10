import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:win10cuassan/models/product.dart';
import 'package:win10cuassan/models/customer.dart';
import 'package:win10cuassan/models/order.dart';

class ApiService {
  final String baseUrl = "http://localhost:5000";
  Future<List<Product>> getProducts() async {
    final url = Uri.parse("$baseUrl/api/products");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<List<Map<String, dynamic>>> getSalesStats() async {
  final url = Uri.parse('$baseUrl/api/sales-stats');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Не удалось загрузить статистику продаж');
  }
}

  Future<List<Map<String, dynamic>>> getInventory() async {
  final url = Uri.parse("$baseUrl/api/inventory");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception("Failed to load inventory");
  }
}


  Future<List<Customer>> getCustomers() async {
    final url = Uri.parse("$baseUrl/api/customers");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load customers");
    }
  }

  Future<Order> getOrder(int id) async {
  final url = Uri.parse("$baseUrl/api/orders/$id");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return Order.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Order not found");
  }
}

  Future<List<Order>> getOrders({int? customerId, String? status}) async {
  var url = Uri.parse("$baseUrl/api/orders");

  if (customerId != null || status != null) {
    final params = <String, String>{};
    if (customerId != null) params['customerId'] = customerId.toString();
    if (status != null) params['status'] = status;
    url = Uri.parse("$baseUrl/api/orders").replace(queryParameters: params);
  }

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((item) => Order.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load orders");
  }
}



  Future<Product> getProduct(int id) async {
    final url = Uri.parse("$baseUrl/api/products/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Product not found");
    }
  }
  


  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    final url = Uri.parse("$baseUrl/api/products");
    final response = await http.post(url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(productData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create product");
    }
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    final url = Uri.parse("$baseUrl/api/products/$productId");
    final response = await http.put(url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(productData),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update product");
    }
  }

  Future<void> deleteProduct(int productId) async {
    final url = Uri.parse("$baseUrl/api/products/$productId");
    final response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception("Failed to delete product");
    }
  }
}