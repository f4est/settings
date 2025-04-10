
import 'package:flutter/material.dart';
import 'package:win10cuassan/models/order.dart';
import 'package:win10cuassan/services/api_service.dart';
import 'package:win10cuassan/pages/order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final ApiService api = ApiService();
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = api.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage(transactionId: order.id),
                    ),
                  ),
                  title: Text('Order #\${order.transactionId}'),
                  subtitle: Text('Customer ID: \${order.customerId} • Total: \$\${order.totalAmount.toStringAsFixed(2)}'),
                  trailing: Text(order.status.name),
                );
              },
            );
          }
        },
      ),
    );
  }
}
