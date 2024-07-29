import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/mainData/database/databases.dart';
import '../../../home/content/news/elements/allNews.dart';
import 'package:ocop/src/page/home/content/news/elements/newsContent.dart';

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

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewContent(news: news),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: news.imageUrl != null
                ? Image.network(
                    news.imageUrl!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'lib/src/assets/img/map/img.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'lib/src/assets/img/map/img.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}