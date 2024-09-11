import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/mainData/database/databases.dart';
import '../../../home/content/news/elements/allNews.dart';
import '../../../home/content/news/elements/newsCard.dart';
import 'package:ocop/mainData/offline/news_offline_storage.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  NewsListState createState() => NewsListState();
}

class NewsListState extends State<NewsList> {
  List<News> news = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void loadNews() {
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      isLoading = true;
    });

    List<News> onlineNews = [];
    List<News> offlineNews = await NewsOfflineStorage.getOfflineNews();

    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      final DefaultDatabaseOptions db = DefaultDatabaseOptions();
      try {
        await db.connect();
        final newsData = await db.getRandomNews(limit: 10);
        for (var item in newsData) {
          final imageUrl = await db.getNewsImage(item['id']);
          onlineNews.add(News(
            id: item['id'] ?? 0,
            title: item['title'] ?? 'Không có tiêu đề',
            publishedAt: item['published_at'] ?? DateTime.now(),
            imageUrl: imageUrl,
          ));
        }
      } catch (e) {
        print('Lỗi khi tải dữ liệu tin tức online: $e');
      } finally {
        await db.close();
      }
    }

    // Combine online and offline news, prioritizing online data
    Map<int, News> newsMap = {};
    for (var newsItem in offlineNews) {
      newsMap[newsItem.id] = newsItem;
    }
    for (var newsItem in onlineNews) {
      newsMap[newsItem.id] = newsItem;
    }

    setState(() {
      news = newsMap.values.toList();
      isLoading = false;
    });
  }

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
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
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
            ),
          ],
        ),
        isLoading
            ? const CircularProgressIndicator()
            : news.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Không có tin tức để hiển thị. Hãy kết nối mạng để tải tin tức mới.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
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