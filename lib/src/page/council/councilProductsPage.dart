// councilProductsPage.dart

import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';
import 'product_evaluation_details_page.dart';

class CouncilProductsPage extends StatefulWidget {
  final int councilId;
  final String councilTitle;

  const CouncilProductsPage({Key? key, required this.councilId, required this.councilTitle}) : super(key: key);

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
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)));
    } else if (_products.isEmpty) {
      return Center(child: Text('Không có sản phẩm nào.'));
    } else {
      return ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ExpansionTile(
            title: Text(product['name']),
            subtitle: Text('Danh mục: ${product['category'] ?? 'Không xác định'}'),
            children: [
              ListTile(
                title: Text('Trạng thái: ${product['status'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Đánh giá: ${product['rating'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Điểm cấp huyện: ${product['district_score'] ?? 'N/A'}'),
                subtitle: Text('Sao cấp huyện: ${product['district_star'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Điểm cấp tỉnh: ${product['province_score'] ?? 'N/A'}'),
                subtitle: Text('Sao cấp tỉnh: ${product['province_star'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Ngày nộp: ${_formatDate(product['submitted_at'])}'),
              ),
              ListTile(
                title: Text('Ngày chấm cấp huyện: ${_formatDate(product['in_district_at'])}'),
              ),
              ListTile(
                title: Text('Ngày chấm cấp tỉnh: ${_formatDate(product['in_province_at'])}'),
              ),
              ListTile(
                title: Text('Ngày hoàn thành: ${_formatDate(product['finalize_at'])}'),
              ),
              ElevatedButton(
                child: Text('Xem chi tiết đánh giá'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductEvaluationDetailsPage(
                        productId: product['id'],
                        councilId: widget.councilId,
                        productName: product['name'],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
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