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
      SELECT p.id, ST_AsText(p.geom) as geom, p.name, p.address, c.name as category_name, p.rating
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
        rating: row[5] as int,
      );
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu: $e');
    return []; // Trả về danh sách trống nếu có lỗi
  }
}

Future<Map<String, int>> getProductRatingCounts() async {
  try {
    final result = await connection!.query('''
      SELECT 
        rating,
        COUNT(*) as count
      FROM 
        public.products
      WHERE 
        rating BETWEEN 1 AND 5
      GROUP BY 
        rating
      ORDER BY 
        rating
    ''');

    Map<String, int> groupedRating = {
      '1': 0, '2': 0, '3': 0, '4': 0, '5': 0
    };

    for (final row in result) {
      int rating = row[0] as int;
      int count = row[1] as int;
      groupedRating[rating.toString()] = count;
    }

    return groupedRating;
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu rating: $e');
    return {
      '1': 0, '2': 0, '3': 0, '4': 0, '5': 0
    };
  }
}

Future<Map<String, int>> getProductCategoryCounts() async {
  try {
    final result = await connection!.query('''
      SELECT 
        c.name AS category_name,
      COUNT(p.id) AS product_count
      FROM 
          public.product_categories c
      LEFT JOIN 
          public.products p ON c.id = p.category_id
      GROUP BY 
          c.id, c.name
      ORDER BY 
        c.name;
    ''');

    Map<String, int> groupedCategory = {
      'Dịch vụ du lịch cộng đồng, du lịch sinh thái và điểm du lịch': 0, 
      'Đồ uống': 0, 
      'Dược liệu và sản phẩm từ dược liệu': 0, 
      'Sinh vật cảnh': 0, 
      'Thủ công mỹ nghệ': 0,
      'Thực phẩm': 0,
    };

    for (final row in result) {
      String group = row[0] as String;
      int count = row[1] as int;
      groupedCategory[group] = count;
    }

    return groupedCategory;
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu group: $e');
    return {
      'Dịch vụ du lịch cộng đồng, du lịch sinh thái và điểm du lịch': 0, 
      'Đồ uống': 0, 
      'Dược liệu và sản phẩm từ dược liệu': 0, 
      'Sinh vật cảnh': 0, 
      'Thủ công mỹ nghệ': 0,
      'Thực phẩm': 0,
    };
  }
}


Future<Map<String, int>> getProductGroupCounts() async {
  try {
    final result = await connection!.query('''
      SELECT 
        pg.name AS group_name,
      COUNT(p.id) AS product_count
      FROM 
        product_groups pg
      LEFT JOIN 
        products p ON pg.id = p.group_id
      GROUP BY 
        pg.name
      ORDER BY 
        pg.name;
    ''');

    Map<String, int> groupedGroup = {
      'Cà phê, cao cao': 0, 
      'Cây cảnh': 0, 
      'Chè': 0, 
      'Dịch vụ du lịch cộng đồng, du lịch sinh thái và điểm du lịch': 0, 
      'Động vật cảnh': 0,
      'Đồ uống có cồn': 0,
      'Đồ uống không cồn': 0,
      'Gia vị': 0,
      'Hoa': 0,
      'Mỹ phẩm có thành phần từ thảo dược': 0,
      'Thủ công mỹ nghệ gia dụng, trang trí': 0,
      'Thực phẩm chế biến': 0,
      'Thực phẩm chức năng, thuốc từ dược liệu, thuốc Y học cổ truyền': 0,
      'Thực phẩm thô, sơ chế': 0,
      'Thực phẩm tươi sống': 0,
      'Tinh dầu và thảo dược khác': 0,
      'Vải, may mặc': 0,
    };

    for (final row in result) {
      String category = row[0] as String;
      int count = row[1] as int;
      groupedGroup[category] = count;
    }

    return groupedGroup;
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu category: $e');
    return {
      'Cà phê, cao cao': 0, 
      'Cây cảnh': 0, 
      'Chè': 0, 
      'Dịch vụ du lịch cộng đồng, du lịch sinh thái và điểm du lịch': 0, 
      'Động vật cảnh': 0,
      'Đồ uống có cồn': 0,
      'Đồ uống không cồn': 0,
      'Gia vị': 0,
      'Hoa': 0,
      'Mỹ phẩm có thành phần từ thảo dược': 0,
      'Thủ công mỹ nghệ gia dụng, trang trí': 0,
      'Thực phẩm chế biến': 0,
      'Thực phẩm chức năng, thuốc từ dược liệu, thuốc Y học cổ truyền': 0,
      'Thực phẩm thô, sơ chế': 0,
      'Thực phẩm tươi sống': 0,
      'Tinh dầu và thảo dược khác': 0,
      'Vải, may mặc': 0,
    };
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
