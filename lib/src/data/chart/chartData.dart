class ChartData {
  final String name;
  final String title;
  final String x_title;
  final String y_title;
  final Map<String, int> data;
  final Map<String, int>? detailedData;
  final bool useDetailedDataForTable;

  ChartData({
    required this.name,
    required this.title,
    required this.x_title,
    required this.y_title,
    required this.data,
    this.detailedData,
    this.useDetailedDataForTable = false,
  });
}