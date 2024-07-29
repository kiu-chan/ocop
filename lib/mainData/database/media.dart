import 'package:postgres/postgres.dart';

class MediaDatabase {
  final PostgreSQLConnection connection;

  MediaDatabase(this.connection);

  Future<List<Map<String, dynamic>>> getMedia() async {
  final result = await connection!.query('SELECT * FROM public.media');
  List<Map<String, dynamic>> mediaList = [];

  for (var row in result) {
    mediaList.add({
      'id': row[0],
      'responsive_images': row[14], // Assuming responsive_images is the 5th column
      // Add other fields if needed
    });
  }

  return mediaList;
}
}