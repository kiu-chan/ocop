// councils.dart
import 'package:postgres/postgres.dart';

class CouncilsDatabase {
  final PostgreSQLConnection connection;

  CouncilsDatabase(this.connection);

  Future<List<Map<String, dynamic>>> getCouncilList() async {
    try {
      final result = await connection.query('''
        SELECT cg.id, cg.title, cg.level, cg.created_at, cg.is_archived, md.name as district_name
        FROM _ocop_evaluation_council_groups cg
        LEFT JOIN map_districts md ON cg.district_id = md.id
        WHERE cg.deleted_at IS NULL
        ORDER BY cg.created_at DESC
      ''');
      
      return result.map((row) => {
        'id': row[0],
        'title': row[1],
        'name': row[1],
        'level': row[2],
        'created_at': row[3],
        'is_archived': row[4],
        'district_name': row[5] ?? 'Không xác định',
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn danh sách hội đồng: $e');
      return [];
    }
  }
}