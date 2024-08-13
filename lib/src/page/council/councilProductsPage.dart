import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';
import 'productEvaluationDetails.dart';

class CouncilProductsPage extends StatefulWidget {
  final int councilId;
  final String councilTitle;

  const CouncilProductsPage({super.key, required this.councilId, required this.councilTitle});

  @override
  _CouncilProductsPageState createState() => _CouncilProductsPageState();
}

class _CouncilProductsPageState extends State<CouncilProductsPage> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      await _databaseOptions.connect();
      final productsData = await _databaseOptions.getCouncilProducts(widget.councilId);
      setState(() {
        _products = productsData;
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
        title: Text('Sản phẩm của ${widget.councilTitle}'),
      ),
      body: _buildBody(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    } else if (_products.isEmpty) {
      return const Center(child: Text('Không có sản phẩm nào.'));
    } else {
      return ListView.separated(
        itemCount: _products.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final product = _products[index];
          return ExpansionTile(
            title: Text(
              product['name'] ?? 'Không có tên',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Danh mục: ${product['category'] ?? 'Không xác định'}'),
            children: [
              buildInfoTile('Trạng thái', product['status']?.toString() ?? 'N/A'),
              buildInfoTile('Đánh giá', product['rating']?.toString() ?? 'N/A'),
              buildInfoTile('Điểm cấp huyện', product['district_score']?.toString() ?? 'N/A'),
              buildInfoTile('Sao cấp huyện', product['district_star']?.toString() ?? 'N/A'),
              buildInfoTile('Điểm cấp tỉnh', product['province_score']?.toString() ?? 'N/A'),
              buildInfoTile('Sao cấp tỉnh', product['province_star']?.toString() ?? 'N/A'),
              buildInfoTile('Ngày nộp', _formatDate(product['submitted_at'])),
              buildInfoTile('Ngày chấm cấp huyện', _formatDate(product['in_district_at'])),
              buildInfoTile('Ngày chấm cấp tỉnh', _formatDate(product['in_province_at'])),
              buildInfoTile('Ngày hoàn thành', _formatDate(product['finalize_at'])),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: ElevatedButton(
    child: const Text(
      'Xem chi tiết đánh giá',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // Thay cho primary
      foregroundColor: Colors.white, // Thay cho onPrimary
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductEvaluationDetails(
            productId: product['id'],
            councilId: widget.councilId,
            productName: product['name'] ?? 'Không có tên',
          ),
        ),
      );
    },
  ),
),
            ],
          );
        },
      );
    }
  }

  Widget buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      } catch (e) {
        print('Lỗi khi chuyển đổi ngày: $e');
        return date;
      }
    }
    return 'N/A';
  }

  @override
  void dispose() {
    _databaseOptions.close();
    super.dispose();
  }
}