import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';

class ProductEvaluationDetails extends StatefulWidget {
  final int productId;
  final int councilId;
  final String productName;

  const ProductEvaluationDetails({
    super.key,
    required this.productId,
    required this.councilId,
    required this.productName,
  });

  @override
  _ProductEvaluationDetailsState createState() => _ProductEvaluationDetailsState();
}

class _ProductEvaluationDetailsState extends State<ProductEvaluationDetails> {
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
        title: Text('Chi tiết đánh giá: ${widget.productName}'),
        backgroundColor: Colors.blue,
      ),
      body: _buildBody(),
      backgroundColor: Colors.grey[100],
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
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'ID Đánh giá: $_evaluationId',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._evaluationPoints.map((councilData) {
            var points = (councilData['points'] as List).cast<Map<String, dynamic>>();
            var groupedPoints = groupPointsByGroup(points);
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text('Người chấm: ${councilData['council_user_name'] ?? 'Không xác định'}'),
                subtitle: Text('Tổng điểm: ${councilData['total_points'] ?? 'N/A'}'),
                children: [
                  ...groupedPoints.entries.map((groupEntry) {
                    return _buildGroupTile(groupEntry.key, groupEntry.value);
                  }),
                ],
              ),
            );
          }),
        ],
      );
    }
  }

  Widget _buildGroupTile(String groupName, Map<String, List<Map<String, dynamic>>> subGroups) {
    if (groupName.isEmpty) return const SizedBox.shrink(); // Không hiển thị nếu groupName trống
    return ExpansionTile(
      title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: subGroups.entries.map((subGroupEntry) {
        return _buildSubGroupTile(subGroupEntry.key, subGroupEntry.value);
      }).toList(),
    );
  }

  Widget _buildSubGroupTile(String subGroupName, List<Map<String, dynamic>> criteria) {
    if (subGroupName.isEmpty) return Column(children: criteria.map(_buildCriteriaTile).toList());
    return ExpansionTile(
      title: Text(subGroupName, style: const TextStyle(fontStyle: FontStyle.italic)),
      children: criteria.map(_buildCriteriaTile).toList(),
    );
  }

  Widget _buildCriteriaTile(Map<String, dynamic> point) {
    return ListTile(
      title: Text(point['criteria_name'] ?? 'Không có tên tiêu chí'),
      subtitle: Text('Điểm: ${point['point'] ?? 'N/A'}'),
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          _showCommentDialog(point['criteria_name'] ?? 'Không có tên tiêu chí', point['comment'] ?? 'Không có nhận xét');
        },
      ),
    );
  }

  void _showCommentDialog(String criteriaName, String comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(criteriaName),
          content: Text(comment),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> groupPointsByGroup(List<Map<String, dynamic>> points) {
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedPoints = {};
    for (var point in points) {
      String groupName = point['group_name'] ?? '';
      String subGroupName = point['group_sub_name'] ?? '';
      if (groupName.isEmpty) continue; // Bỏ qua nếu group_name trống
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