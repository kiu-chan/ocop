import 'package:postgres/postgres.dart';

class AreaDatabase {
  final PostgreSQLConnection connection;

  AreaDatabase(this.connection);
  
  Future<List<Map<String, dynamic>>> getApprovedCommunes() async {
    try {
      final result = await connection.query('''
        SELECT id, name
        FROM commune_users
        WHERE approved = true
        ORDER BY id
      ''');

      return result.map((row) => {
        'id': row[0],
        'name': row[1],
      }).toList();
    } catch (e) {
      print('Error fetching communes: $e');
      return [];
    }
  }

}