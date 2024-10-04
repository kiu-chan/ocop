import 'package:postgres/postgres.dart';
import 'dart:convert';

class NewsDatabase {
  final PostgreSQLConnection connection;

  NewsDatabase(this.connection);

  Future<List<Map<String, dynamic>>> getRandomNews({int limit = 10}) async {
    try {
      final result = await connection.query('''
        SELECT id, title, published_at
        FROM posts 
        ORDER BY RANDOM() 
        LIMIT @limit
      ''', substitutionValues: {
        'limit': limit,
      });

      return result
          .map((row) => {
                'id': row[0] as int,
                'title': row[1] as String,
                'published_at': row[2] as DateTime,
              })
          .toList();
    } catch (e) {
      print('Lỗi khi truy vấn tin tức ngẫu nhiên: $e');
      return [];
    }
  }

  Future<String?> getFullNewsContent(String newsTitle) async {
    try {
      final result = await connection.query('''
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
      final result = await connection.query('''
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

  Future<List<Map<String, dynamic>>> getAllNews(
      {int page = 1, int perPage = 10}) async {
    try {
      final offset = (page - 1) * perPage;
      final result = await connection.query('''
        SELECT id, title, published_at
        FROM posts 
        ORDER BY published_at DESC
        LIMIT @limit OFFSET @offset
      ''', substitutionValues: {
        'limit': perPage,
        'offset': offset,
      });

      return result
          .map((row) => {
                'id': row[0] as int,
                'title': row[1] as String,
                'published_at': row[2] as DateTime,
              })
          .toList();
    } catch (e) {
      print('Lỗi khi truy vấn tất cả tin tức: $e');
      return [];
    }
  }

  Future<String?> getNewsImage(int newsId) async {
    try {
      final result = await connection.query('''
      SELECT id, file_name, generated_conversions
      FROM media
      WHERE model_id = @newsId
      AND model_type = 'App\\Models\\Admin\\Post'
      LIMIT 1
    ''', substitutionValues: {
        'newsId': newsId,
      });

      if (result.isNotEmpty) {
        int id = result[0][0] as int;
        String fileName = result[0][1] as String;
        var generatedConversions = result[0][2];

        // Kiểm tra nếu generated_conversions là rỗng hoặc không có conversion md
        bool hasConversions = false;
        if (generatedConversions != null) {
          if (generatedConversions is Map<String, dynamic>) {
            hasConversions = generatedConversions['md'] == true;
          } else if (generatedConversions is String) {
            try {
              Map<String, dynamic> conversions =
                  json.decode(generatedConversions);
              hasConversions = conversions['md'] == true;
            } catch (e) {
              print('Error decoding JSON: $e');
            }
          }
        }

        List<String> parts = fileName.split('.');
        String fileNameWithoutExtension;
        if (parts.length > 1) {
          fileNameWithoutExtension =
              parts.sublist(0, parts.length - 1).join('.');
        } else {
          fileNameWithoutExtension = parts[0];
        }

        if (hasConversions) {
          return 'https://ocopbentre.girc.edu.vn/storage/images/post/$id/conversions/$fileNameWithoutExtension-md.jpg';
        } else {
          return 'https://ocopbentre.girc.edu.vn/storage/images/post/$id/$fileName';
        }
      }
      return null;
    } catch (e) {
      print('Lỗi khi truy vấn hình ảnh tin tức: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAboutsContent(int aboutsId) async {
    try {
      final result = await connection.query('''
        SELECT content, updated_at
        FROM abouts
        WHERE id = @id
      ''', substitutionValues: {
        'id': aboutsId,
      });

      if (result.isNotEmpty) {
        return {
          'content': result[0][0] as String,
          'updated_at': (result[0][1] as DateTime).toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      print('Lỗi khi truy vấn nội dung giới thiệu: $e');
      return null;
    }
  }
}
