import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/mainData/database/databases.dart';
import '../../../home/content/news/elements/allNews.dart';
import '../../../home/content/news/elements/newsCard.dart';

class NewsList extends StatefulWidget {
  const NewsList({Key? key}) : super(key: key);

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  List<News> news = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      isLoading = true;
    });

    List<News> onlineNews = [];
    List<News> offlineNews = []; // Thường sẽ trống vì tin tức không lưu offline

    // Kiểm tra kết nối và tải dữ liệu online nếu có thể
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
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

    // Kết hợp dữ liệu online và offline, ưu tiên dữ liệu online cho tin tức
    Map<int, News> newsMap = {};
    for (var newsItem in onlineNews) {
      newsMap[newsItem.id] = newsItem;
    }
    for (var newsItem in offlineNews) {
      if (!newsMap.containsKey(newsItem.id)) {
        newsMap[newsItem.id] = newsItem;
      }
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
                      "Kết nối mạng để xem thông tin chi tiết",
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