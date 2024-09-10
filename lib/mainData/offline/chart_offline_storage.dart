import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class ChartOfflineStorage {
  static const String _chartDataKey = 'offline_chart_data';

  static Future<void> saveChartData(String identifier, ChartData chartData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allChartData = json.decode(prefs.getString(_chartDataKey) ?? '{}');

    allChartData[identifier] = chartData.toJson();

    await prefs.setString(_chartDataKey, json.encode(allChartData));
  }

  static Future<ChartData?> getChartData(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allChartData = json.decode(prefs.getString(_chartDataKey) ?? '{}');

    if (allChartData.containsKey(identifier)) {
      return ChartData.fromJson(allChartData[identifier]);
    }
    return null;
  }

  static Future<bool> hasOfflineData(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allChartData = json.decode(prefs.getString(_chartDataKey) ?? '{}');
    return allChartData.containsKey(identifier);
  }

  static Future<void> removeChartData(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allChartData = json.decode(prefs.getString(_chartDataKey) ?? '{}');

    allChartData.remove(identifier);

    await prefs.setString(_chartDataKey, json.encode(allChartData));
  }
}