import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';

class ProductEvaluationDetailsPage extends StatefulWidget {
  final int productId;
  final int councilId;
  final String productName;

  const ProductEvaluationDetailsPage({
    super.key,
    required this.productId,
    required this.councilId,
    required this.productName,
  });

  @override
  _ProductEvaluationDetailsPageState createState() => _ProductEvaluationDetailsPageState();
}

class _ProductEvaluationDetailsPageState extends State<ProductEvaluationDetailsPage> {
  final Color groupColor = Colors.blue[100]!;
  final Color subGroupColor = Colors.green[100]!;
  final Color criteriaColor = Colors.orange[100]!;
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();
  int? _evaluationId;
  List<Map<String, dynamic>> _evaluationPoints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      await _databaseOptions.connect();
      final evaluationId = await _databaseOptions.getProductEvaluationId(widget.productId);
      if (evaluationId != null) {
        final points = await _databaseOptions.getEvaluationPoints(evaluationId);
        setState(() {
          _evaluationId = evaluationId;
          _evaluationPoints = points;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy ID đánh giá.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi khi tải dữ liệu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá: ${widget.productName}'),
      ),
      body: _buildBody(),
    );
  }

Widget _buildBody() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  } else if (_errorMessage.isNotEmpty) {
    return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
  } else if (_evaluationPoints.isEmpty) {
    return const Center(child: Text('Không có dữ liệu đánh giá.'));
  } else {
    return ListView(
      children: [
        ListTile(
          title: Text(
            'ID Đánh giá: $_evaluationId',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        ..._evaluationPoints.map((councilData) {
          var points = (councilData['points'] as List).cast<Map<String, dynamic>>();
          var groupedPoints = groupPointsByGroup(points);
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('Người chấm: ${councilData['council_user_name']}'),
              subtitle: Text('Tổng điểm: ${councilData['total_points']}'),
              children: [
                ...groupedPoints.entries.map((groupEntry) {
                  return Card(
                    color: groupColor,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ExpansionTile(
                      title: Text(groupEntry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        ...groupEntry.value.entries.map((subGroupEntry) {
                          return Card(
                            color: subGroupColor,
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                            child: ExpansionTile(
                              title: Text(subGroupEntry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                              children: [
                                ...subGroupEntry.value.map((point) {
                                  return Card(
                                    color: criteriaColor,
                                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 24),
                                    child: ExpansionTile(
                                      title: Text('${point['criteria_name']}'),
                                      subtitle: Text('Điểm: ${point['point']}'),
                                      children: [
                                        ListTile(
                                          title: Text('Nhận xét: ${point['comment']}'),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}

  Map<String, Map<String, List<Map<String, dynamic>>>> groupPointsByGroup(List<Map<String, dynamic>> points) {
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedPoints = {};
    for (var point in points) {
      String groupName = point['group_name'] ?? 'Không xác định';
      String subGroupName = point['group_sub_name'] ?? 'Không xác định';
      if (!groupedPoints.containsKey(groupName)) {
        groupedPoints[groupName] = {};
      }
      if (!groupedPoints[groupName]!.containsKey(subGroupName)) {
        groupedPoints[groupName]![subGroupName] = [];
      }
      groupedPoints[groupName]![subGroupName]!.add(point);
    }

    // Sắp xếp các phần theo thứ tự
    var sortedGroups = Map.fromEntries(
      groupedPoints.entries.toList()
        ..sort((a, b) {
          int orderA = a.value.values.first.first['group_order'] as int? ?? 9999;
          int orderB = b.value.values.first.first['group_order'] as int? ?? 9999;
          return orderA.compareTo(orderB);
        })
    );

    // Sắp xếp các nhóm trong mỗi phần theo thứ tự
    sortedGroups.forEach((groupName, subGroups) {
      sortedGroups[groupName] = Map.fromEntries(
        subGroups.entries.toList()
          ..sort((a, b) {
            int orderA = a.value.first['group_sub_order'] as int? ?? 9999;
            int orderB = b.value.first['group_sub_order'] as int? ?? 9999;
            return orderA.compareTo(orderB);
          })
      );
    });

    // Sắp xếp các tiêu chí trong mỗi nhóm theo thứ tự
    sortedGroups.forEach((groupName, subGroups) {
      subGroups.forEach((subGroupName, criterias) {
        sortedGroups[groupName]![subGroupName] = criterias
          ..sort((a, b) {
            int orderA = a['criteria_order'] as int? ?? 9999;
            int orderB = b['criteria_order'] as int? ?? 9999;
            return orderA.compareTo(orderB);
          });
      });
    });

    return sortedGroups;
  }

  @override
  void dispose() {
    _databaseOptions.close();
    super.dispose();
  }
}