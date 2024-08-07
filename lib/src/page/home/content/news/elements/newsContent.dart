import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class NewContent extends StatefulWidget {
  final News news;

  const NewContent({super.key, required this.news});

  @override
  _NewContentState createState() => _NewContentState();
}

class _NewContentState extends State<NewContent> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullContent();
  }

  Future<void> _loadFullContent() async {
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
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news.title),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // AspectRatio(
                  //   aspectRatio: 16 / 9, 
                  //   child: Image.asset(
                  //     'lib/src/assets/img/map/img.png',
                  //     width: double.infinity,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
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
                  Center(child: const Logo()),
                ],
              ),
            ),
    );
  }
}