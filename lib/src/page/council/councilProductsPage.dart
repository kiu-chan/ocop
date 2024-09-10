import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';
import 'productEvaluationDetails.dart';
import 'package:ocop/mainData/offline/council_offline_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
  bool _isOffline = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoadData();
  }

  Future<void> _checkConnectivityAndLoadData() async {
    bool result = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isOffline = !result;
      _isLoading = true;
    });
    await _loadProducts();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProducts() async {
    try {
      if (_isOffline) {
        await _loadOfflineProducts();
      } else {
        await _loadOnlineProducts();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi khi tải dữ liệu: $e';
      });
    }
  }

  Future<void> _loadOfflineProducts() async {
    final offlineProducts = await CouncilOfflineStorage.getProductList(widget.councilId);
    setState(() {
      _products = offlineProducts;
    });
  }

  Future<void> _loadOnlineProducts() async {
    await _databaseOptions.connect();
    final productsData = await _databaseOptions.getCouncilProducts(widget.councilId);
    
    // Convert DateTime fields to strings before saving
    final convertedProductsData = productsData.map((product) {
      return {
        ...product,
        'submitted_at': _formatDate(product['submitted_at']),
        'in_district_at': _formatDate(product['in_district_at']),
        'in_province_at': _formatDate(product['in_province_at']),
        'finalize_at': _formatDate(product['finalize_at']),
      };
    }).toList();

    await CouncilOfflineStorage.saveProductList(widget.councilId, convertedProductsData);
    setState(() {
      _products = convertedProductsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm của ${widget.councilTitle}'),
        actions: [
          if (_isOffline)
            IconButton(
              icon: const Icon(Icons.cloud_off),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang ở chế độ offline')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkConnectivityAndLoadData,
          ),
        ],
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
              buildInfoTile('Ngày nộp', product['submitted_at'] ?? 'N/A'),
              buildInfoTile('Ngày chấm cấp huyện', product['in_district_at'] ?? 'N/A'),
              buildInfoTile('Ngày chấm cấp tỉnh', product['in_province_at'] ?? 'N/A'),
              buildInfoTile('Ngày hoàn thành', product['finalize_at'] ?? 'N/A'),
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
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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