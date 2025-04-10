
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final ApiService api = ApiService();
  late Future<List<Customer>> futureCustomers;
  String _search = '';

  @override
  void initState() {
    super.initState();
    futureCustomers = api.getCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Поиск заказчика',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: futureCustomers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: \${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет заказчиков'));
                } else {
                  final customers = snapshot.data!
                      .where((c) =>
                          c.firstName.toLowerCase().contains(_search.toLowerCase()) ||
                          c.lastName.toLowerCase().contains(_search.toLowerCase()) ||
                          (c.email?.toLowerCase().contains(_search.toLowerCase()) ?? false))
                      .toList();
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return ListTile(
                        title: Text('\${c.firstName} \${c.lastName}'),
                        subtitle: Text(c.email ?? 'Без email'),
                        trailing: Text(c.membershipStatus),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
