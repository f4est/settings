import 'package:flutter/material.dart';
import 'package:win10cuassan/services/api_service.dart';
import 'package:win10cuassan/pages/products_detail_page.dart';
import 'package:win10cuassan/models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ApiService api = ApiService();
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = api.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(productId: p.productId),
                    ),
                  ),
                  title: Text(p.productName),
                  subtitle: Text('Price: ${p.price}'),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Пример: создать продукт
          await api.createProduct({
            "ProductName": "Test product",
            "Category": "Breads",
            "Price": 99.0,
            "Cost": 50.0,
            "Description": "From Flutter",
            "Seasonal": false,
            "Active": true,
            "IntroducedDate": "2023-01-01",
            "Ingredients": "Flour, Water"
          });
          setState(() {
            futureProducts = api.getProducts();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
