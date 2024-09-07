import 'package:flutter/material.dart';
import 'package:ocop/src/page/home/content/products/products.dart';
import 'package:ocop/src/page/home/content/news/news.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/home/content/videos/videoList.dart';
import 'package:ocop/src/page/home/content/companies/companyList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ProductListState> _productListKey = GlobalKey();
  final GlobalKey<NewsListState> _newsListKey = GlobalKey();
  final GlobalKey<CompanyListState> _companyListKey = GlobalKey();
  final GlobalKey<VideoListState> _videoListKey = GlobalKey();

  Future<void> _handleRefresh() async {
    // Reload all components
    _productListKey.currentState?.loadProducts();
    _newsListKey.currentState?.loadNews();
    _companyListKey.currentState?.loadCompanies();
    _videoListKey.currentState?.loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Logo(),
              const SizedBox(height: 10),
              ProductList(key: _productListKey),
              NewsList(key: _newsListKey),
              CompanyList(key: _companyListKey),
              const SizedBox(height: 20),
              VideoList(key: _videoListKey),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}