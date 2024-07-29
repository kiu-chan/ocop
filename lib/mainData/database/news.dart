import 'package:latlong2/latlong.dart';
import 'package:postgres/postgres.dart';
import 'package:ocop/src/data/map/productData.dart';

class NewsDatabase {
  final PostgreSQLConnection connection;

  NewsDatabase(this.connection);

  Future<List<Map<String, dynamic>>> getRandomNews({int limit = 10}) async {
    try {
      final result = await connection!.query('''
        SELECT id, title, published_at
        FROM posts 
        ORDER BY RANDOM() 
        LIMIT @limit
      ''', substitutionValues: {
        'limit': limit,
      });

      return result.map((row) => {
        'id': row[0] as int,
        'title': row[1] as String,
        'published_at': row[2] as DateTime,
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn tin tức ngẫu nhiên: $e');
      return [];
    }
  }

  Future<String?> getFullNewsContent(String newsTitle) async {
  try {
    final result = await connection!.query('''
      SELECT content
      FROM posts
      WHERE title = @title
      LIMIT 1
    ''', substitutionValues: {
      'title': newsTitle,
    });

    if (result.isNotEmpty) {
      return result[0][0] as String?;
    }
    return null;
  } catch (e) {
    print('Lỗi khi truy vấn nội dung đầy đủ của tin tức: $e');
    return null;
  }
}

  Future<String?> getNewsContent(int newsId) async {
    try {
      final result = await connection!.query('''
        SELECT content
        FROM posts
        WHERE id = @id
      ''', substitutionValues: {
        'id': newsId,
      });

      if (result.isNotEmpty) {
        return result[0][0] as String?;
      }
      return null;
    } catch (e) {
      print('Lỗi khi truy vấn nội dung tin tức: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllNews({int page = 1, int perPage = 10}) async {
    try {
      final offset = (page - 1) * perPage;
      final result = await connection!.query('''
        SELECT id, title, published_at
        FROM posts 
        ORDER BY published_at DESC
        LIMIT @limit OFFSET @offset
      ''', substitutionValues: {
        'limit': perPage,
        'offset': offset,
      });

      return result.map((row) => {
        'id': row[0] as int,
        'title': row[1] as String,
        'published_at': row[2] as DateTime,
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn tất cả tin tức: $e');
      return [];
    }
  }
}