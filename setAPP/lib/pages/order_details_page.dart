
import 'package:flutter/material.dart';
import 'package:win10cuassan/models/order.dart';
import 'package:win10cuassan/services/api_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final int transactionId;

  const OrderDetailsPage({super.key, required this.transactionId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ApiService api = ApiService();
  late Future<Order> futureOrder;

  @override
  void initState() {
    super.initState();
    futureOrder = api.getOrder(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #\${widget.transactionId}')),
      body: FutureBuilder<Order>(
        future: futureOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Order not found'));
          } else {
            final order = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer ID: \${order.customerId}'),
                  const SizedBox(height: 8),
                  Text('Date: \${order.orderDate}'),
                  const SizedBox(height: 8),
                  Text('Total Amount: \$\${order.totalAmount}'),
                  const SizedBox(height: 8),
                  Text('Status: \${order.status}'),
                  const SizedBox(height: 8),
                  Text('Payment Method: \${order.paymentMethod}'),
                  const SizedBox(height: 8),
                  Text('Channel: \${order.channel}'),
                  const SizedBox(height: 8),
                  Text('Store ID: \${order.storeId ?? "-"}'),
                  const SizedBox(height: 8),
                  Text('Promotion ID: \${order.promotionId ?? "-"}'),
                  const SizedBox(height: 8),
                  Text('Discount: \$\${order.discountAmount ?? 0}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
