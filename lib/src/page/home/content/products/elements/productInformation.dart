import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/elements/star.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:html/parser.dart' show parse;

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
    _loadProductDetails();
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
  setState(() {
    if (content != null) {
      widget.product.describe = _convertHtmlToPlainText(content);
    }
    widget.product.imageUrls = images;
    widget.product.address = address ?? 'Không có thông tin';
    isLoading = false;
  });
  await db.close();
}

  String _convertHtmlToPlainText(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body!.text).documentElement!.text;
    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.length : 1,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (widget.product.imageUrls.isNotEmpty) {
                        return Image.network(
                          widget.product.imageUrls[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'lib/src/assets/img/home/image.png',
                              fit: BoxFit.contain,
                            );
                          },
                        );
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
                                color: currentImageIndex == index ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Image.network(
                              widget.product.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'lib/src/assets/img/home/image.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            "Số sao đạt:",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Star(value: widget.product.star),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Danh mục: ${widget.product.category}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Địa chỉ: ${widget.product.address}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                  child: widget.product.describe != null && widget.product.describe!.isNotEmpty
                      ? Text(widget.product.describe!)
                      : const Text('Không có mô tả cho sản phẩm này.'),
                ),
                const SizedBox(height: 20),
                const Center(child: Logo()),
              ],
            ),
    );
  }
}