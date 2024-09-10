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

  // Phương thức chuyển đối tượng ChartData thành Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'x_title': x_title,
      'y_title': y_title,
      'data': data,
      'detailedData': detailedData,
      'useDetailedDataForTable': useDetailedDataForTable,
    };
  }

  // Phương thức tạo đối tượng ChartData từ Map
  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      name: json['name'],
      title: json['title'],
      x_title: json['x_title'],
      y_title: json['y_title'],
      data: Map<String, int>.from(json['data']),
      detailedData: json['detailedData'] != null 
          ? Map<String, int>.from(json['detailedData']) 
          : null,
      useDetailedDataForTable: json['useDetailedDataForTable'] ?? false,
    );
  }
}