import 'order_item.dart';

enum OrderStatus { pending, processing, completed, cancelled }

OrderStatus parseStatus(String status) {
  switch (status.toLowerCase()) {
    case 'processing':
      return OrderStatus.processing;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

class Order {
  final int id;
  final String customerName;
  final DateTime date;
  final double total;
  OrderStatus status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['TransactionId'],
      customerName: json['CustomerName'],
      date: DateTime.parse(json['OrderDate']),
      total: (json['TotalAmount'] as num).toDouble(),
      status: parseStatus(json['Status']),
      items: [], // пока что пусто, если OrderItem не передаётся в JSON
    );
  }
}
