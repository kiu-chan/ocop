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

      return result
          .map((row) => {
                'id': row[0],
                'name': row[1],
              })
          .toList();
    } catch (e) {
      print('Error fetching communes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllCommunes() async {
    try {
      final result = await connection.query(
          'SELECT id, name, ST_AsText(geom) as geom_text FROM map_communes');

      return result.map((row) {
        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'geom_text': row[2] as String?,
        };
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu communes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCommune(int id) async {
    try {
      final result = await connection.query(
        'SELECT id, name, ST_AsText(geom) as geom_text, area, population FROM map_communes WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isNotEmpty) {
        var row = result[0];
        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'geom_text': row[2] as String?,
          'area': row[3] is String ? double.parse(row[3]) : row[3] as double,
          'population': row[4] is String ? int.parse(row[4]) : row[4] as int,
        };
      }
      return null;
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu commune: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDistricts() async {
    try {
      final result = await connection.query(
          'SELECT id, name, ST_AsText(geom) as geom_text, area, population, updated_year, color FROM map_districts');

      return result.map((row) {
        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'geom_text': row[2] as String?,
          'area': row[3] as String,
          'population': row[4] as String,
          'updated_year': row[5] as String,
          'color': row[6] as String,
        };
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu huyện: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDistrict(int id) async {
    try {
      final result = await connection.query(
        'SELECT id, name, ST_AsText(geom) as geom_text, area, population, updated_year, color FROM map_districts WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isNotEmpty) {
        var row = result[0];
        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'geom_text': row[2] as String?,
          'area': row[3] as String,
          'population': row[4] as String,
          'updated_year': row[5] as String,
          'color': row[6] as String,
        };
      }
      return null;
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu huyện: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getBorders() async {
    try {
      final result = await connection.query(
          'SELECT id, ST_AsText(geom) as geom_text, shape_lenght FROM map_borders');

      return result.map((row) {
        return {
          'id': row[0] as int,
          'geom_text': row[1] as String?,
          'shape_lenght': row[2] as double?,
        };
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu biên giới: $e');
      return [];
    }
  }

Future<int> getProductCountForCommune(int communeId) async {
  try {
    final result = await connection.query('''
      SELECT COUNT(*) as product_count
      FROM products
      WHERE commune_id = @communeId
    ''', substitutionValues: {
      'communeId': communeId,
    });

    if (result.isNotEmpty) {
      return result[0][0] as int;
    }
    return 0;
  } catch (e) {
    print('Lỗi khi truy vấn số lượng sản phẩm của xã: $e');
    return 0;
  }
}
}
