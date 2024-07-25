import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/elements/star.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/databases.dart';
import 'package:html/parser.dart' show parse;

class ProductInformation extends StatefulWidget {
  final Product product;

  const ProductInformation({super.key, required this.product});

  @override
  _ProductInformationState createState() => _ProductInformationState();
}

class _ProductInformationState extends State<ProductInformation> {
  String? productContent;
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();

  @override
  void initState() {
    super.initState();
    _loadProductContent();
  }

  Future<void> _loadProductContent() async {
    await db.connect();
    final content = await db.getProductContent(widget.product.id);
    setState(() {
      if (content != null) {
        productContent = _convertHtmlToPlainText(content);
        widget.product.describe = productContent;
      }
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
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(8),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.product.img != null && widget.product.img!.isNotEmpty)
                    Image.network(
                      widget.product.img!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.asset(
                      'lib/src/assets/img/map/img.png',
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    )
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Câu chuyện sản phẩm",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: widget.product.describe != null
                      ? Text(widget.product.describe!)
                      : const CircularProgressIndicator(),
                  ),
                  const Logo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}