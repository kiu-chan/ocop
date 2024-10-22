import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ocop/mainData/offline/offline_storage_service.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/elements/star.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:html/parser.dart' show parse;
import 'package:url_launcher/url_launcher.dart';
import 'package:ocop/src/page/home/content/companies/companyDetails.dart';

class ProductInformation extends StatefulWidget {
  final ProductHome product;

  const ProductInformation({super.key, required this.product});

  @override
  _ProductInformationState createState() => _ProductInformationState();
}

class _ProductInformationState extends State<ProductInformation> {
  bool isLoading = true;
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  int currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.product.isOfflineAvailable) {
      setState(() {
        isLoading = false;
      });
    } else {
      _loadProductDetails();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      isLoading = true;
    });
    await db.connect();
    final content = await db.getProductContent(widget.product.id);
    final images = await db.getProductImages(widget.product.id);
    final address = await db.getProductAddress(widget.product.id);
    final details = await db.getProductDetails(widget.product.id);

    setState(() {
      if (content != null) {
        widget.product.describe = _convertHtmlToPlainText(content);
      }
      widget.product.imageUrls = images;
      widget.product.address = address ?? 'Không có thông tin';
      widget.product.companyName = details['company_name'];
      widget.product.companyId = details['company_id'];
      widget.product.phoneNumber = details['phone_number'];
      widget.product.representative = details['representative'];
      widget.product.email = details['email'];
      widget.product.website = details['website'];
      widget.product.latitude = details['latitude'];
      widget.product.longitude = details['longitude'];
      isLoading = false;
    });
    await db.close();
  }

  String _convertHtmlToPlainText(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }

  void _openMap(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      final uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Không thể mở bản đồ');
      }
    } else {
      print('Không có thông tin vị trí');
    }
  }

  void _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Không thể mở URL: $url');
      }
    } else {
      print('URL không hợp lệ');
    }
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Không thể gọi điện thoại đến số: $phoneNumber');
      }
    } else {
      print('Số điện thoại không hợp lệ');
    }
  }

Widget _buildImageWidget(String imageData) {
  if (imageData.startsWith('http')) {
    // Đây là URL
    return Image.network(
      imageData,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'lib/src/assets/img/home/image.png',
          fit: BoxFit.contain,
        );
      },
    );
  } else {
    // Giả sử đây là dữ liệu base64
    try {
      return Image.memory(
        base64Decode(imageData),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'lib/src/assets/img/home/image.png',
            fit: BoxFit.contain,
          );
        },
      );
    } catch (e) {
      // Nếu không thể giải mã base64, hiển thị hình ảnh mặc định
      return Image.asset(
        'lib/src/assets/img/home/image.png',
        fit: BoxFit.contain,
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          if (!widget.product.isOfflineAvailable)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                await OfflineStorageService.saveProduct(widget.product);
                setState(() {
                  widget.product.isOfflineAvailable = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sản phẩm đã được lưu để xem offline')),
                );
              },
            ),
          if (widget.product.isOfflineAvailable)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await OfflineStorageService.removeProduct(widget.product.id);
                setState(() {
                  widget.product.isOfflineAvailable = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Sản phẩm đã được xóa khỏi bộ nhớ offline')),
                );
              },
            ),
        ],
      ),
      body: isLoading && !widget.product.isOfflineAvailable
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.product.imageUrls.isNotEmpty
                        ? widget.product.imageUrls.length
                        : 1,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (widget.product.imageUrls.isNotEmpty) {
                        return _buildImageWidget(
                            widget.product.imageUrls[index]);
                      } else {
                        return Image.asset(
                          'lib/src/assets/img/home/image.png',
                          fit: BoxFit.contain,
                        );
                      }
                    },
                  ),
                ),
                if (widget.product.imageUrls.isNotEmpty)
                  Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: currentImageIndex == index
                                    ? Colors.blue
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: _buildImageWidget(
                                widget.product.imageUrls[index]),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: Star(value: widget.product.star)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Tên sản phẩm: ${widget.product.name}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            "Số sao đạt:",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Star(value: widget.product.star),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Danh mục: ${widget.product.category}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Địa chỉ: ${widget.product.address}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Cơ sở sản xuất: ${widget.product.companyName ?? 'Không có thông tin'}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (widget.product.companyId != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompanyDetails(
                                        companyId: widget.product.companyId!),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (widget.product.phoneNumber != null &&
                          widget.product.phoneNumber!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Số điện thoại: ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () =>
                                  _makePhoneCall(widget.product.phoneNumber),
                              child: Text(
                                widget.product.phoneNumber!,
                                style: TextStyle(
                                  color: Colors.blue[100],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          "Số điện thoại: Không có thông tin",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        "Người đại diện: ${widget.product.representative ?? 'Không có thông tin'}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Email: ${widget.product.email ?? 'Không có thông tin'}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (widget.product.website != null &&
                          widget.product.website!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Trang web: ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () => _launchURL(widget.product.website),
                              child: Text(
                                'Truy cập trang web',
                                style: TextStyle(
                                  color: Colors.blue[100],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          "Trang web: Không có thông tin",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _openMap(
                            widget.product.latitude, widget.product.longitude),
                        child: const Text('Xem trên bản đồ',
                            style: TextStyle(color: Colors.blue)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      "Câu chuyện sản phẩm",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.product.describe != null &&
                          widget.product.describe!.isNotEmpty
                      ? Text(
                          widget.product.describe!,
                          textAlign: TextAlign.justify,
                        )
                      : const Text('Không có mô tả cho sản phẩm này.'),
                ),
                const SizedBox(height: 20),
                const Center(child: Logo()),
              ],
            ),
    );
  }
}
