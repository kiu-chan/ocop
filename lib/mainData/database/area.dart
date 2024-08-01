import 'package:postgres/postgres.dart';
import 'package:latlong2/latlong.dart';

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
    Future<List<Map<String, dynamic>>> getAllCommunes() async {
    try {
      final result = await connection!.query(
        'SELECT id, name, ST_AsText(geom) as geom_text FROM map_communes'
      );

      return result.map((row) {
        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'polygons': _parseMultiPolygon(row[2] as String),
        };
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu communes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCommune(int id) async {
    try {
      final result = await connection!.query(
        'SELECT id, name, ST_AsText(geom) as geom_text, area, population FROM map_communes WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isNotEmpty) {
        var row = result[0];
        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'polygons': _parseMultiPolygon(row[2] as String),
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

  List<List<LatLng>> _parseMultiPolygon(String wkt) {
    List<List<LatLng>> polygons = [];
    String coordinatesStr = wkt.split('MULTIPOLYGON(((')[1].split(')))')[0];
    List<String> polygonStrs = coordinatesStr.split(')),((');

    for (String polygonStr in polygonStrs) {
      List<LatLng> points = polygonStr.split(',').map((coord) {
        var parts = coord.trim().split(' ');
        return LatLng(double.parse(parts[1]), double.parse(parts[0]));
      }).toList();
      polygons.add(points);
    }

    return polygons;
  }

}