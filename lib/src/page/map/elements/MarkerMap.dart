import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ocop/config/map.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/src/data/map/productMapData.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/elements/star.dart';
import 'package:ocop/src/page/home/content/products/elements/productInformation.dart';
import 'package:ocop/src/page/home/content/companies/companyDetails.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkerMap extends StatefulWidget {
  final List<ImageData> imageDataList;
  final List<CompanyData> companies;
  final List<ProductData> products;
  final Set<String> selectedProductTypes;

  const MarkerMap({
    super.key,
    required this.imageDataList,
    required this.companies,
    required this.products,
    required this.selectedProductTypes,
  });

  @override
  _MarkerMapState createState() => _MarkerMapState();
}

class _MarkerMapState extends State<MarkerMap> {
  bool _isLoading = false;

  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: _buildMarkers(context) +
          _buildCompanyMarkers() +
          (MapConfig.showProducts
              ? _buildProductMarkers(context)
              : []), // Only build product markers if showProducts is true
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
                  ProductData? product = _findProductByLocationAndCategory(
                      location, imageData.title);
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

  List<Marker> _buildCompanyMarkers() {
    return widget.companies
        .where((company) =>
            widget.selectedProductTypes.contains(company.productTypeName))
        .map((company) {
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
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (company.logoUrl != null)
                          SizedBox(
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: 16 / 9, // Tỷ lệ khung hình 16:9
                              child: Image.network(
                                company.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.business, size: 100),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text('Loại sản phẩm: ${company.productTypeName}'),
                        if (company.address != null)
                          Text('Địa chỉ: ${company.address}'),
                        if (company.phoneNumber != null)
                          InkWell(
                            child: Text('Số điện thoại: ${company.phoneNumber}',
                                style: const TextStyle(color: Colors.blue)),
                            onTap: () => _makePhoneCall(company.phoneNumber!),
                          ),
                        if (company.email != null)
                          Text('Email: ${company.email}'),
                        if (company.website != null)
                          InkWell(
                            child: Text('Website: ${company.website}',
                                style: const TextStyle(color: Colors.blue)),
                            onTap: () => _launchURL(company.website!),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Xem chi tiết'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CompanyDetails(companyId: company.id),
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
    return widget.products
        .where((product) =>
            widget.selectedProductTypes.contains(product.categoryName))
        .map((product) {
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
            child: const Icon(Icons.shopping_basket,
                color: Colors.white, size: 30),
          ),
        ),
      );
    }).toList();
  }

  ProductData? _findProductByLocationAndCategory(
      LatLng location, String category) {
    try {
      return widget.products.firstWhere(
        (product) =>
            product.location == location && product.categoryName == category,
      );
    } catch (e) {
      return null;
    }
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
      if (!_isLoading) return;

      final content = await db.getProductContent(product.id);
      final images = await db.getProductImages(product.id);
      final address = await db.getProductAddress(product.id);
      final details = await db.getProductDetails(product.id);

      if (!_isLoading) return;

      Navigator.of(context).pop();

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
                  if (images.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          images[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text('Địa chỉ: ${address ?? "Không có thông tin"}'),
                  Text('Loại sản phẩm: ${product.categoryName}'),
                  Row(
                    children: [
                      const Text('Đánh giá: '),
                      Star(value: product.rating),
                    ],
                  ),
                  if (details['phone_number'] != null)
                    Text('Liên hệ: ${details['phone_number']}'),
                  if (details['company_name'] != null)
                    Text('Cơ sở sản xuất: ${details['company_name']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Xem chi tiết'),
                onPressed: () {
                  Navigator.of(context).pop();
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
      Navigator.of(context).pop();
    } finally {
      await db.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Không thể gọi điện thoại đến số: $phoneNumber');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Không thể mở URL: $url');
    }
  }
}
