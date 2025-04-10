import 'package:flutter/material.dart';
import 'pages/products_page.dart';
import 'pages/orders_page.dart';
import 'pages/customers_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/inventory_page.dart';

void main() {
  runApp(const BelleCroissantApp());
}

class BelleCroissantApp extends StatelessWidget {
  const BelleCroissantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belle Croissant Lyonnais',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
        brightness: Brightness.light,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    OrdersPage(),
    ProductsPage(),
    CustomersPage(),
    InventoryPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Orders',
    'Products',
    'Customers',
    'Inventory',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(
                  icon: Icon(Icons.receipt_long), label: Text('Orders')),
              NavigationRailDestination(
                  icon: Icon(Icons.shopping_bag), label: Text('Products')),
              NavigationRailDestination(
                  icon: Icon(Icons.people), label: Text('Customers')),
              NavigationRailDestination(
                  icon: Icon(Icons.inventory), label: Text('Inventory')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(_titles[_selectedIndex]),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}