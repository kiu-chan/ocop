import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/page/home/content/news/elements/newsContent.dart';

class AllNews extends StatefulWidget {
  const AllNews({Key? key}) : super(key: key);

  @override
  _AllNewsState createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  List<News> allNews = [];
  List<News> filteredNews = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMoreNews = true;
  static const int _newsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadAllNews();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadAllNews() async {
    if (!_hasMoreNews) return;
    
    final db = DefaultDatabaseOptions();
    await db.connect();
    
    try {
      final newsData = await db.getAllNews(page: _currentPage, perPage: _newsPerPage);
      setState(() {
        if (newsData.isEmpty) {
          _hasMoreNews = false;
        } else {
          allNews.addAll(newsData.map((item) => News(
            id: item['id'] ?? 0,
            title: item['title'] ?? 'Không có tiêu đề',
            publishedAt: item['published_at'] ?? DateTime.now(),
          )));
          filteredNews = List.from(allNews);
          _currentPage++;
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading all news: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      await db.close();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadAllNews();
    }
  }

  void _filterNews(String query) {
    setState(() {
      filteredNews = allNews
          .where((news) => news.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả tin tức'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm tin tức',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _filterNews,
            ),
          ),
          Expanded(
            child: isLoading && allNews.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredNews.length + (_hasMoreNews ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < filteredNews.length) {
                        return NewsCard(news: filteredNews[index]);
                      } else if (_hasMoreNews) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.asset(
                'lib/src/assets/img/map/img.png', // Thay thế bằng hình ảnh thực tế của tin tức
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      news.formattedDate,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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