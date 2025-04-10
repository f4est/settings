
import 'package:flutter/material.dart';
import 'package:win10cuassan/models/product.dart';
import 'package:win10cuassan/services/api_service.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ApiService api = ApiService();
  late Future<Product> futureProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = api.getProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product #\${widget.productId}')),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Product not found'));
          } else {
            final p = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: \${p.productName}', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text('Category: \${p.category}'),
                  Text('Price: \$\${p.price}'),
                  Text('Cost: \$\${p.cost}'),
                  Text('Seasonal: \${p.seasonal ? "Yes" : "No"}'),
                  Text('Active: \${p.active ? "Yes" : "No"}'),
                  Text('Introduced: \${p.introducedDate.toLocal().toString().split(" ")[0]}'),
                  const SizedBox(height: 10),
                  Text('Ingredients:\${p.ingredients ?? "-"}'),
                  const SizedBox(height: 10),
                  Text('Description:\${p.description ?? "-"}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
