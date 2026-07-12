import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/chart.dart';

/// Loads and parses chart files from assets.
class ChartLoader {
  /// Load a chart JSON file from assets/charts/
  static Future<Chart> loadChart(String filename) async {
    final jsonString =
        await rootBundle.loadString('assets/charts/$filename');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Chart.fromJson(json);
  }

  /// Load chart from a raw JSON string (for bundled/default charts)
  static Chart parseChart(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Chart.fromJson(json);
  }
}
