import 'package:latlong2/latlong.dart';
import 'package:postgres/postgres.dart';
import 'package:ocop/src/data/map/productData.dart';

class DefaultDatabaseOptions {
  PostgreSQLConnection? connection;

  Future<void> connect() async {
    connection = PostgreSQLConnection(
      '163.44.193.74',  // Địa chỉ máy chủ PostgreSQL
      5432,         // Cổng của PostgreSQL
      'bentre_ocop', // Tên cơ sở dữ liệu
      username: 'postgres', // Tên người dùng
      password: 'yfti*m0xZYtRy3QfF)tV',       // Mật khẩu
    );
    
    await connection!.open();
    print('Connected to PostgreSQL database.');
  }

  // Tách tọa độ từ chuỗi
  // RegExp regex = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)');
  // Match match = regex.firstMatch();

Future<List<ProductData>> getProducts() async {
  try {
    final result = await connection!.query('''
      SELECT p.id, ST_AsText(p.geom) as geom, p.name, p.address, c.name as category_name 
      FROM public.products p
      JOIN public.product_categories c ON p.category_id = c.id
    ''');

    return result.map((row) {
      final geomText = row[1] as String;
      final coordinates = geomText.split('(')[1].split(')')[0].split(' ');
      return ProductData(
        id: row[0] as int,
        location: LatLng(
          double.parse(coordinates[1]),
          double.parse(coordinates[0]),
        ),
        name: row[2] as String,
        address: row[3] as String?,
        categoryName: row[4] as String,
      );
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu: $e');
    return []; // Trả về danh sách trống nếu có lỗi
  }
}

  Future<List<Map<String, dynamic>>> getProductProcesses() async {
  final result = await connection!.query('SELECT * FROM public.product_processes');
  List<Map<String, dynamic>> productProcesses = [];

  for (var row in result) {
    productProcesses.add({
      'id': row[0],
      'product_id': row[1],
      'content': row[2],
      'created_at': row[3],
      'updated_at': row[4],
    });
  }

    return productProcesses;
  }

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

  Future<void> close() async {
    await connection!.close();
    print('Connection closed.');
  }
}
