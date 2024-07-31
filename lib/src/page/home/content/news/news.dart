import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/mainData/database/databases.dart';
import '../../../home/content/news/elements/allNews.dart';
import '../../../home/content/news/elements/newsCard.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  List<News> news = [];
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    await db.connect();
    final newsData = await db.getRandomNews(limit: 10);
    for (var item in newsData) {
      final imageUrl = await db.getNewsImage(item['id']);
      setState(() {
        news.add(News(
          id: item['id'] ?? 0,
          title: item['title'] ?? 'Không có tiêu đề',
          publishedAt: item['published_at'] ?? DateTime.now(),
          imageUrl: imageUrl,
        ));
      });
    }
    setState(() {
      isLoading = false;
    });
    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tin tức",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllNews()),
                  );
                },
                child: const Text(
                  "Xem tất cả",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 600,
                child: ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    return NewsCard(news: news[index]);
                  },
                ),
              ),
      ],
    );
  }
}

