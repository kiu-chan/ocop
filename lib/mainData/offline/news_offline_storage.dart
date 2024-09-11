import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ocop/src/data/home/newsData.dart';

class NewsOfflineStorage {
  static const String _newsKey = 'offline_news';

  static Future<void> saveNews(News news) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNews = prefs.getStringList(_newsKey) ?? [];

    // Download and encode image
    String? encodedImage;
    if (news.imageUrl != null) {
      try {
        final response = await http.get(Uri.parse(news.imageUrl!));
        if (response.statusCode == 200) {
          encodedImage = base64Encode(response.bodyBytes);
        }
      } catch (e) {
        print('Error downloading image: $e');
      }
    }

    // Convert News to JSON string
    String newsJson = jsonEncode({
      'id': news.id,
      'title': news.title,
      'publishedAt': news.publishedAt.toIso8601String(),
      'content': news.content,
      'encodedImage': encodedImage,
    });

    savedNews.add(newsJson);
    await prefs.setStringList(_newsKey, savedNews);
  }

  static Future<List<News>> getOfflineNews() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNews = prefs.getStringList(_newsKey) ?? [];

    List<News> result = [];
    for (String newsJson in savedNews) {
      try {
        Map<String, dynamic> newsMap = jsonDecode(newsJson);
        String? imageUrl;
        if (newsMap['encodedImage'] != null) {
          try {
            // Verify if the base64 string is valid
            base64Decode(newsMap['encodedImage']);
            imageUrl = 'data:image/jpeg;base64,${newsMap['encodedImage']}';
          } catch (e) {
            print('Error decoding image: $e');
            imageUrl = null;
          }
        }
        result.add(News(
          id: newsMap['id'],
          title: newsMap['title'],
          publishedAt: DateTime.parse(newsMap['publishedAt']),
          content: newsMap['content'],
          imageUrl: imageUrl,
        ));
      } catch (e) {
        print('Error parsing news item: $e');
      }
    }
    return result;
  }

  static Future<void> removeNews(int newsId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNews = prefs.getStringList(_newsKey) ?? [];

    savedNews.removeWhere((newsJson) {
      Map<String, dynamic> newsMap = jsonDecode(newsJson);
      return newsMap['id'] == newsId;
    });

    await prefs.setStringList(_newsKey, savedNews);
  }

  static Future<bool> isNewsSaved(int newsId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNews = prefs.getStringList(_newsKey) ?? [];

    return savedNews.any((newsJson) {
      Map<String, dynamic> newsMap = jsonDecode(newsJson);
      return newsMap['id'] == newsId;
    });
  }
}