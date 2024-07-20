import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/src/page/home/content/news/elements/newsCard.dart';

class NewsList extends StatelessWidget {
  final List<News> news = [
    News(name: 'Tin tức 1', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    News(name: 'Tin tức 2', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    News(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    News(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    News(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    News(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    News(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    // Thêm các tin tức khác vào đây
  ];

  NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
            padding: const EdgeInsets.only(left: 10.0), 
            child: const Text(
              "Tin tức",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
                ), // Văn bản in đậm
            ),
          ),
            Container(
            padding: const EdgeInsets.only(right: 10.0), 
            child: const Text(
              "All",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
                ), // Văn bản in đậm
            ),
          ),
          ],
        ),
        SizedBox(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: news.length,
              itemBuilder: (context, index) {
                return NewsCard(news: news[index]);
              },
            )),
      ],
    );
  }
}
