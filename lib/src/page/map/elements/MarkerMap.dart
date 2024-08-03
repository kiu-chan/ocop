import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/src/data/map/productMapData.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/home/content/products/elements/productInformation.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:latlong2/latlong.dart';

class MarkerMap extends StatefulWidget {
  final List<ImageData> imageDataList;
  final List<CompanyData> companies;
  final List<ProductData> products;
  final Set<String> selectedProductTypes;

  const MarkerMap({
    Key? key,
    required this.imageDataList,
    required this.companies,
    required this.products,
    required this.selectedProductTypes,
  }) : super(key: key);

  @override
  _MarkerMapState createState() => _MarkerMapState();
}

class _MarkerMapState extends State<MarkerMap> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: _buildMarkers(context) + _buildCompanyMarkers() + _buildProductMarkers(context),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    List<Marker> markers = [];
    for (var imageData in widget.imageDataList) {
      if (imageData.checkRender) {
        for (var location in imageData.locations) {
          markers.add(
            Marker(
              width: 50.0,
              height: 50.0,
              point: location,
              builder: (ctx) => GestureDetector(
                onTap: () {
                  ProductData? product = _findProductByLocationAndCategory(location, imageData.title);
                  if (product != null) {
                    _showProductInfo(ctx, product);
                  } else {
                    showDialog(
                      context: ctx,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(imageData.title),
                          content: Image.asset(imageData.imagePath),
                        );
                      },
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    image: DecorationImage(
                      image: AssetImage(imageData.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    return markers;
  }

  ProductData? _findProductByLocationAndCategory(LatLng location, String category) {
    try {
      return widget.products.firstWhere(
        (product) => product.location == location && product.categoryName == category,
      );
    } catch (e) {
      return null;
    }
  }

  List<Marker> _buildCompanyMarkers() {
    return widget.companies.where((company) => widget.selectedProductTypes.contains(company.productTypeName)).map((company) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: company.location,
        builder: (ctx) => GestureDetector(
          onTap: () {
            showDialog(
              context: ctx,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(company.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại sản phẩm: ${company.productTypeName}'),
                      Text('Vị trí: ${company.location.latitude}, ${company.location.longitude}'),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 30),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildProductMarkers(BuildContext context) {
    return widget.products.where((product) => widget.selectedProductTypes.contains(product.categoryName)).map((product) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: product.location,
        builder: (ctx) => GestureDetector(
          onTap: () {
            _showProductInfo(ctx, product);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.shopping_basket, color: Colors.white, size: 30),
          ),
        ),
      );
    }).toList();
  }

  void _showProductInfo(BuildContext context, ProductData product) async {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  const Text("Đang load..."),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    final db = DefaultDatabaseOptions();
    await db.connect();

    try {
      if (!_isLoading) return; // Kiểm tra xem quá trình tải có bị hủy không

      final content = await db.getProductContent(product.id);
      final images = await db.getProductImages(product.id);
      final address = await db.getProductAddress(product.id);
      final details = await db.getProductDetails(product.id);

      if (!_isLoading) return; // Kiểm tra lại sau khi tải xong

      Navigator.of(context).pop(); // Đóng dialog loading

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(product.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.isNotEmpty) Image.network(images[0]),
                  const SizedBox(height: 10),
                  Text('Địa chỉ: ${address ?? "Không có thông tin"}'),
                  Text('Loại sản phẩm: ${product.categoryName}'),
                  Text('Đánh giá: ${product.rating} sao'),
                  if (details['phone_number'] != null)
                    Text('Liên hệ: ${details['phone_number']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Xem chi tiết'),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductInformation(
                        product: ProductHome(
                          id: product.id,
                          name: product.name,
                          star: product.rating,
                          category: product.categoryName,
                          img: images.isNotEmpty ? images[0] : null,
                          address: address,
                          describe: content,
                          companyName: details['company_name'],
                          phoneNumber: details['phone_number'],
                          representative: details['representative'],
                          email: details['email'],
                          website: details['website'],
                          latitude: details['latitude'],
                          longitude: details['longitude'],
                        ),
                      ),
                    ),
                  );
                },
              ),
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
    } catch (e) {
      print('Lỗi khi tải thông tin sản phẩm: $e');
      Navigator.of(context).pop(); // Đóng dialog loading
      // Hiển thị thông báo lỗi nếu cần
    } finally {
      await db.close();
      setState(() {
        _isLoading = false;
      });
    }
  }
}