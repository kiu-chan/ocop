import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';

class ProductEvaluationDetailsPage extends StatefulWidget {
  final int productId;
  final int councilId;
  final String productName;

  const ProductEvaluationDetailsPage({
    Key? key,
    required this.productId,
    required this.councilId,
    required this.productName,
  }) : super(key: key);

  @override
  _ProductEvaluationDetailsPageState createState() => _ProductEvaluationDetailsPageState();
}

class _ProductEvaluationDetailsPageState extends State<ProductEvaluationDetailsPage> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();
  List<Map<String, dynamic>> _evaluationDetails = [];
  Map<int, List<Map<String, dynamic>>> _evaluationPoints = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEvaluationDetails();
  }

  Future<void> _loadEvaluationDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      await _databaseOptions.connect();
      final details = await _databaseOptions.getProductEvaluationDetails(widget.productId, widget.councilId);
      
      for (var detail in details) {
        int councilUserId = detail['council_user_id'];
        int evaluationId = detail['evaluation_id'];
        List<Map<String, dynamic>> points = await _databaseOptions.getEvaluationPoints(councilUserId, evaluationId);
        _evaluationPoints[councilUserId] = points;
      }

      setState(() {
        _evaluationDetails = details;
        _isLoading = false;
      });
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
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)));
    } else if (_evaluationDetails.isEmpty) {
      return Center(child: Text('Không có dữ liệu đánh giá.'));
    } else {
      return ListView.builder(
        itemCount: _evaluationDetails.length,
        itemBuilder: (context, index) {
          final detail = _evaluationDetails[index];
          final councilUserId = detail['council_user_id'];
          final points = _evaluationPoints[councilUserId] ?? [];
          return ExpansionTile(
            title: Text('Người chấm ID: $councilUserId'),
            subtitle: Text('Đánh giá ID: ${detail['evaluation_id']}'),
            children: [
              ListTile(
                title: Text('Điểm cấp huyện: ${detail['district_score'] ?? 'N/A'}'),
                subtitle: Text('Sao cấp huyện: ${detail['district_star'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Điểm cấp tỉnh: ${detail['province_score'] ?? 'N/A'}'),
                subtitle: Text('Sao cấp tỉnh: ${detail['province_star'] ?? 'N/A'}'),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Chi tiết điểm đánh giá:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...points.map((point) => ListTile(
                title: Text('Tiêu chí: ${point['score_board_criteria_id']}'),
                subtitle: Text('Điểm: ${point['point']}'),
              )),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _databaseOptions.close();
    super.dispose();
  }
}