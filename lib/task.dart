import 'dart:io';

import 'package:csv/csv.dart';

void task() {
  try {
    print(
        'Enter the name or the path of the input file (including the .csv extension):');
    final inputFileName = stdin.readLineSync();
    final inputCsvFile = File(inputFileName!);

    final inputCsvData = inputCsvFile.readAsStringSync();
    final csvRows = const CsvToListConverter().convert(inputCsvData);

    final productQuantities = <String, double>{};
    final brandCounts = <String, Map<String, int>>{};

    for (var row in csvRows) {
      final productName = row[2];
      final quantity = row[3];
      final brand = row[4];

      if (quantity is num) {
        productQuantities.update(productName, (value) => value + quantity,
            ifAbsent: () => quantity.toDouble());
      }

      if (brandCounts.containsKey(productName)) {
        final brandMap = brandCounts[productName]!;
        brandMap.update(brand, (value) => value + 1, ifAbsent: () => 1);
      } else {
        brandCounts[productName] = {brand: 1};
      }
    }

    final averageQuantityFile = File('0_$inputFileName');
    final popularBrandFile = File('1_$inputFileName');

    final averageQuantityCsv = productQuantities.entries
        .map((entry) => [entry.key, entry.value / csvRows.length])
        .toList();
    averageQuantityFile
        .writeAsString(const ListToCsvConverter().convert(averageQuantityCsv));

    final popularBrandCsv = brandCounts.entries
        .map((entry) => [entry.key, entry.value.entries.first.key])
        .toList();
    popularBrandFile
        .writeAsString(const ListToCsvConverter().convert(popularBrandCsv));

    print('Your files are ready.');
  } catch (e) {
    print('File not found please enter name or the path correctly.');
    task();
  }
}
