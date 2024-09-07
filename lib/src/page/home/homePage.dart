import 'package:flutter/material.dart';
import 'package:ocop/src/page/home/content/products/products.dart';
import 'package:ocop/src/page/home/content/news/news.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/home/content/videos/videoList.dart';
import 'package:ocop/src/page/home/content/companies/companyList.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Logo(),
            SizedBox(height: 10),
            ProductList(),
            // NewsList(),
            // CompanyList(),
            // SizedBox(height: 20),
            // VideoList(),
            // SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}