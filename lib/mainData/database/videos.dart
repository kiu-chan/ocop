import 'package:postgres/postgres.dart';
import 'package:ocop/src/data/home/videosData.dart';

class VideosDatabase {
  final PostgreSQLConnection connection;

  VideosDatabase(this.connection);

  Future<List<VideoData>> getAllVideo() async {
    try {
      final result = await connection.query(
        'SELECT video_id, title FROM videos ORDER BY id'
      );

      return result.map((row) => VideoData(
        id: row[0] as String,
        title: row[1] as String,
      )).toList();
    } catch (e) {
      print('Lỗi khi truy vấn tất cả video: $e');
      return [];
    }
  }
}