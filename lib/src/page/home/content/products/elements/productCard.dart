import 'package:flutter/material.dart';
import 'package:ocop/mainData/offline/offline_storage_service.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/home/content/products/elements/productInformation.dart';
import 'package:ocop/src/page/elements/star.dart';

class ProductCard extends StatefulWidget {
  final ProductHome product;
  
  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isDownloading = false;

  void _downloadProduct() async {
    setState(() {
      _isDownloading = true;
    });
    await OfflineStorageService.saveProduct(widget.product);
    setState(() {
      widget.product.isOfflineAvailable = true;
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductInformation(product: widget.product),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Center(
                      child: widget.product.img != null && widget.product.img!.isNotEmpty
                        ? Image.network(
                            widget.product.img!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'lib/src/assets/img/home/image.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'lib/src/assets/img/home/image.png',
                            fit: BoxFit.cover,
                          ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: widget.product.isOfflineAvailable
                        ? Icon(Icons.offline_pin, color: Colors.green)
                        : IconButton(
                            icon: _isDownloading 
                              ? CircularProgressIndicator() 
                              : Icon(Icons.download),
                            onPressed: _downloadProduct,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Star(value: widget.product.star),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}