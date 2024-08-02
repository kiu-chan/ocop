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

Future<List<Map<String, dynamic>>> getAllDistricts() async {
  try {
    final result = await connection!.query(
      'SELECT id, name, ST_AsText(geom) as geom_text, area, population, updated_year, color FROM map_districts'
    );

    return result.map((row) {
      List<List<LatLng>> polygons = [];
      try {
        polygons = _parseMultiPolygon(row[2] as String);
      } catch (e) {
        print('Lỗi khi phân tích dữ liệu địa lý cho huyện ${row[1]}: $e');
      }

      return {
        'id': row[0] as int,
        'name': row[1] as String,
        'polygons': polygons,
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
    final result = await connection!.query(
      'SELECT id, name, ST_AsText(geom) as geom_text, area, population, updated_year, color FROM map_districts WHERE id = @id',
      substitutionValues: {'id': id},
    );

    if (result.isNotEmpty) {
      var row = result[0];
      return {
        'id': row[0] as int,
        'name': row[1] as String,
        'polygons': _parseMultiPolygon(row[2] as String),
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

List<List<LatLng>> _parseMultiPolygon(String wkt) {
  List<List<LatLng>> polygons = [];
  try {
    String coordinatesStr = wkt.split('MULTIPOLYGON(((')[1].split(')))')[0];
    List<String> polygonStrs = coordinatesStr.split(')),((');

    for (String polygonStr in polygonStrs) {
      List<LatLng> points = polygonStr.split(',').map((coord) {
        var parts = coord.trim().split(' ');
        if (parts.length != 2) {
          print('Invalid coordinate: $coord');
          return null;
        }
        try {
          double lat = double.parse(parts[1]);
          double lng = double.parse(parts[0]);
          return LatLng(lat, lng);
        } catch (e) {
          print('Error parsing coordinate: $coord');
          return null;
        }
      }).where((point) => point != null).cast<LatLng>().toList();
      
      if (points.isNotEmpty) {
        polygons.add(points);
      }
    }
  } catch (e) {
    print('Error parsing MultiPolygon: $e');
  }

  return polygons;
}

}