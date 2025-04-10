import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:win10cuassan/services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final api = ApiService();
  late Future<List<Map<String, dynamic>>> futureSales;
  late Future<List<Map<String, dynamic>>> futureInventory;

  @override
  void initState() {
    super.initState();
    futureSales = api.getSalesStats();
    futureInventory = api.getInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('График продаж', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureSales,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Ошибка: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Нет данных');
                } else {
                  final salesByDay = snapshot.data!;
                  return BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= salesByDay.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                salesByDay[index]['day'],
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: salesByDay.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sales = entry.value['sales'];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(toY: (sales as num).toDouble(), width: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          Text('Диаграмма запасов', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureInventory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Ошибка: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Нет данных');
                } else {
                  final inventory = snapshot.data!;
                  return PieChart(
                    PieChartData(
                      sections: inventory.map((item) {
                        final quantity = (item['quantity'] as num).toDouble();
                        final label = item['name'];
                        return PieChartSectionData(
                          value: quantity,
                          title: '$label (${item['quantity']})',
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
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
