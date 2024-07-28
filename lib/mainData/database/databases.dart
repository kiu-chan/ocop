import 'package:latlong2/latlong.dart';
import 'package:postgres/postgres.dart';
import 'package:ocop/src/data/map/productData.dart';
import 'package:bcrypt/bcrypt.dart';

class DefaultDatabaseOptions {
  bool _connectionFailed = false;

  PostgreSQLConnection? connection;

  Future<void> connect() async {
    try {
      connection = PostgreSQLConnection(
        '163.44.193.74',
        5432,
        'bentre_ocop',
        username: 'postgres',
        password: 'yfti*m0xZYtRy3QfF)tV',
      );
      
      await connection!.open();
      print('Connected to PostgreSQL database.');
      _connectionFailed = false;
    } catch (e) {
      print('Failed to connect to database: $e');
      _connectionFailed = true;
    }
  }
  bool get connectionFailed => _connectionFailed;

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

  Future<Map<String, dynamic>?> checkUserCredentials(String email, String password) async {
    try {
      final result = await connection!.query('''
        SELECT id, name, email, password, commune_id
        FROM company_users
        WHERE email = @email AND approved = true
      ''', substitutionValues: {
        'email': email,
      });

      if (result.isNotEmpty) {
        String storedHash = result[0][3]; // Assuming password is the 4th column
        if (BCrypt.checkpw(password, storedHash)) {
          return {
            'id': result[0][0],
            'name': result[0][1],
            'email': result[0][2],
            'commune_id': result[0][4],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error checking user credentials: $e');
      return null;
    }
  }


  Future<List<Map<String, dynamic>>> getApprovedCommunes() async {
    try {
      final result = await connection!.query('''
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

  Future<bool> checkUserExists(String email) async {
    try {
      final result = await connection!.query(
        'SELECT COUNT(*) FROM company_users WHERE email = @email',
        substitutionValues: {'email': email},
      );
      return (result[0][0] as int) > 0;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  Future<bool> createUser(String name, String email, String password, int communeId) async {
    try {
      // Mã hóa mật khẩu sử dụng bcrypt
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      await connection!.query('''
        INSERT INTO company_users (
          approved,
          created_at,
          updated_at,
          deleted_at,
          email_verified_at,
          name,
          email,
          password,
          remember_token,
          commune_id
        ) VALUES (
          true,
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP,
          NULL,
          CURRENT_TIMESTAMP,
          @name,
          @email,
          @hashedPassword,
          NULL,
          @communeId
        )
      ''', substitutionValues: {
        'name': name,
        'email': email,
        'hashedPassword': hashedPassword,
        'communeId': communeId,
      });
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRandomProducts() async {
  try {
    final result = await connection!.query('''
      SELECT id, name, rating
      FROM public.products
      ORDER BY RANDOM()
      LIMIT 10
    ''');

    return result.map((row) => {
      'id': row[0] as int,
      'name': row[1] as String,
      'rating': row[2] as int,
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn 10 sản phẩm ngẫu nhiên: $e');
    return []; // Trả về danh sách trống nếu có lỗi
  }
}

Future<List<Map<String, dynamic>>> getAllProducts() async {
  try {
    final result = await connection!.query('''
      SELECT p.id, p.name, p.rating, c.name as category_name
      FROM public.products p
      LEFT JOIN public.product_categories c ON p.category_id = c.id
      ORDER BY p.name
    ''');

    return result.map((row) => {
      'id': row[0] as int,
      'name': row[1] as String,
      'rating': row[2] as int,
      'category': row[3] as String?, // Có thể null nếu không có danh mục
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn tất cả sản phẩm: $e');
    return [];
  }
}


Future<String?> getProductContent(int productId) async {
  try {
    final result = await connection!.query('''
      SELECT content
      FROM public.products
      WHERE id = @id
    ''', substitutionValues: {
      'id': productId,
    });

    if (result.isNotEmpty) {
      return result[0][0] as String?;
    }
    return null;
  } catch (e) {
    print('Lỗi khi truy vấn nội dung sản phẩm: $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>> getRandomNews({int limit = 10}) async {
  try {
    final result = await connection!.query('''
      SELECT id, title, published_at
      FROM posts 
      ORDER BY RANDOM() 
      LIMIT @limit
    ''', substitutionValues: {
      'limit': limit,
    });

    return result.map((row) => {
      'id': row[0] as int,
      'title': row[1] as String,
      'published_at': row[2] as DateTime,
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn tin tức ngẫu nhiên: $e');
    return [];
  }
}

Future<String?> getFullNewsContent(String newsTitle) async {
  try {
    final result = await connection!.query('''
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

  Future<List<Map<String, dynamic>>> getAllNews({int page = 1, int perPage = 10}) async {
    try {
      final offset = (page - 1) * perPage;
      final result = await connection!.query('''
        SELECT id, title, published_at
        FROM posts 
        ORDER BY published_at DESC
        LIMIT @limit OFFSET @offset
      ''', substitutionValues: {
        'limit': perPage,
        'offset': offset,
      });

      return result.map((row) => {
        'id': row[0] as int,
        'title': row[1] as String,
        'published_at': row[2] as DateTime,
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn tất cả tin tức: $e');
      return [];
    }
  }

  Future<String?> getNewsContent(int newsId) async {
    try {
      final result = await connection!.query('''
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

  Future<void> close() async {
    await connection!.close();
    print('Connection closed.');
  }
}
