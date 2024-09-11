import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:ocop/mainData/offline/news_offline_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NewContent extends StatefulWidget {
  final News news;

  const NewContent({super.key, required this.news});

  @override
  _NewContentState createState() => _NewContentState();
}

class _NewContentState extends State<NewContent> {
  bool isLoading = true;
  bool isOfflineSaved = false;

  @override
  void initState() {
    super.initState();
    _loadFullContent();
    _checkOfflineStatus();
  }

  Future<void> _checkOfflineStatus() async {
    bool saved = await NewsOfflineStorage.isNewsSaved(widget.news.id);
    setState(() {
      isOfflineSaved = saved;
    });
  }

  Future<void> _loadFullContent() async {
    setState(() {
      isLoading = true;
    });

    bool isOnline = await InternetConnectionChecker().hasConnection;

    if (isOnline) {
      final db = DefaultDatabaseOptions();
      await db.connect();
      
      try {
        final content = await db.getNewsContent(widget.news.id);
        setState(() {
          widget.news.content = content ?? 'Không thể tải nội dung.';
          isLoading = false;
        });
      } catch (e) {
        print('Error loading full content: $e');
        setState(() {
          widget.news.content = 'Đã xảy ra lỗi khi tải nội dung.';
          isLoading = false;
        });
      } finally {
        await db.close();
      }
    } else {
      // Load offline content
      List<News> offlineNews = await NewsOfflineStorage.getOfflineNews();
      News? offlineNewsItem = offlineNews.firstWhere(
        (news) => news.id == widget.news.id,
        orElse: () => widget.news,
      );
      setState(() {
        widget.news.content = offlineNewsItem.content ?? 'Không có nội dung offline.';
        widget.news.imageUrl = offlineNewsItem.imageUrl;
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildImage() {
    if (widget.news.imageUrl != null) {
      if (widget.news.imageUrl!.startsWith('data:image')) {
        // This is a base64 encoded image
        return Image.memory(
          Uri.parse(widget.news.imageUrl!).data!.contentAsBytes(),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading base64 image: $error');
            return _buildFallbackImage();
          },
        );
      } else {
        // This is a network image
        return Image.network(
          widget.news.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return _buildFallbackImage();
          },
        );
      }
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      'lib/src/assets/img/img.jpg',
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news.title),
        actions: [
          IconButton(
            icon: Icon(isOfflineSaved ? Icons.offline_pin : Icons.offline_pin_outlined),
            onPressed: () async {
              if (isOfflineSaved) {
                await NewsOfflineStorage.removeNews(widget.news.id);
              } else {
                await NewsOfflineStorage.saveNews(widget.news);
              }
              await _checkOfflineStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isOfflineSaved
                      ? 'Đã xóa tin tức khỏi bộ nhớ offline'
                      : 'Đã lưu tin tức để xem offline'),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImage(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.news.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ngày đăng: ${_formatDate(widget.news.publishedAt)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Html(
                          data: widget.news.content,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16),
                              lineHeight: const LineHeight(1.5),
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                  const Center(child: Logo()),
                ],
              ),
            ),
    );
  }
}