import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../services/api_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ApiService api = ApiService();
  late Future<List<Map<String, dynamic>>> futureInventory;

  @override
  void initState() {
    super.initState();
    futureInventory = api.getInventory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureInventory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет данных'));
        } else {
          final inventory = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Запасы', style: Theme.of(context).textTheme.headlineSmall),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _exportToCsv(context, inventory),
                          icon: const Icon(Icons.table_view),
                          label: const Text('Экспорт CSV'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _exportToPdf(context, inventory),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Экспорт PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Название')),
                        DataColumn(label: Text('Количество')),
                        DataColumn(label: Text('Ед. изм.')),
                      ],
                      rows: inventory
                          .map((item) => DataRow(cells: [
                                DataCell(Text(item['name'])),
                                DataCell(Text(item['quantity'].toString())),
                                DataCell(Text(item['unit'])),
                              ]))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _exportToCsv(BuildContext context, List<Map<String, dynamic>> inventory) async {
    final rows = [
      ['Название', 'Количество', 'Ед. изм.'],
      ...inventory.map((item) => [item['name'], item['quantity'], item['unit']]),
    ];
    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/inventory_report.csv');
    await file.writeAsString(csvData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV сохранён: ${file.path}')));
  }

  void _exportToPdf(BuildContext context, List<Map<String, dynamic>> inventory) async {
    final pdf = pw.Document();
    final tableRows = [
      ['Название', 'Количество', 'Ед. изм.'],
      ...inventory.map((item) => [item['name'], '${item['quantity']}', item['unit']]),
    ];

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            data: tableRows,
            cellStyle: const pw.TextStyle(fontSize: 12),
            headerStyle: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/inventory_report.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF сохранён: ${file.path}')));
  }
}
