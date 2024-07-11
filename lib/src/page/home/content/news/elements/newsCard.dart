import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/src/page/home/content/news/elements/newsContent.dart';

class NewsCard extends StatelessWidget {
  final News news;

  NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewContent(news: news),
            ),
          );
        },
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(news.name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              // Text('${news.news} đ'),
            ],
          ),
        ),
      ),
    );
  }
}