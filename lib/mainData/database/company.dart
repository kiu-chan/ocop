import 'package:latlong2/latlong.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:postgres/postgres.dart';
import 'package:ocop/src/data/map/companiesData.dart';

class CompanyDatabase {
  final PostgreSQLConnection connection;

  CompanyDatabase(this.connection);
  
Future<List<CompanyData>> getCompanies() async {
  try {
    final result = await connection.query('''
      SELECT 
        ST_AsText(pc.geom) as geom,
        pc.type_id,
        pc.name AS company_name,
        pt.name AS product_type_name,
        pc.id,
        m.id as media_id,
        m.file_name,
        pc.address,
        pc.phone_number
      FROM 
        product_companies pc
      JOIN 
        product_types pt ON pc.type_id = pt.id
      LEFT JOIN
        media m ON pc.id = m.model_id AND m.collection_name = 'logo'
    ''');

    return result.map((row) {
      final geomText = row[0] as String;
      final coordinates = geomText.split('(')[1].split(')')[0].split(' ');
      String? logoUrl;
      if (row[5] != null && row[6] != null) {
        logoUrl = 'https://ocop.bentre.gov.vn/storage/images/company/${row[5]}/${row[6]}';
      }
      return CompanyData(
        location: LatLng(
          double.parse(coordinates[1]),
          double.parse(coordinates[0]),
        ),
        typeId: row[1] as int,
        name: row[2] as String,
        productTypeName: row[3] as String,
        id: row[4] as int,
        logoUrl: logoUrl,
        address: row[7] as String?,
        phoneNumber: row[8] as String?,
      );
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu công ty: $e');
    return []; // Trả về danh sách trống nếu có lỗi
  }
}

Future<List<Company>> getRandomCompanies({int limit = 10}) async {
  try {
    final result = await connection.query('''
      SELECT pc.id, pc.name, m.id as media_id, m.file_name
      FROM product_companies pc
      LEFT JOIN media m ON pc.id = m.model_id AND m.collection_name = 'logo'
      ORDER BY RANDOM()
      LIMIT @limit
    ''', substitutionValues: {
      'limit': limit,
    });

    return result.map((row) {
      String? logoUrl;
      if (row[2] != null && row[3] != null) {
        logoUrl = 'https://ocop.bentre.gov.vn/storage/images/company/${row[2]}/${row[3]}';
      }
      return Company(
        id: row[0] as int,
        name: row[1] as String,
        logoUrl: logoUrl,
      );
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn danh sách công ty ngẫu nhiên: $e');
    return [];
  }
}

Future<Company?> getCompanyDetails(int id) async {
  try {
    final companyResult = await connection.query('''
      SELECT pc.id, pc.name, pc.introduction, pc.address, pc.phone_number, pc.representative, pc.website, pc.email,
             m.id as media_id, m.file_name, mc.name as commune_name, md.name as district_name,
             ST_X(pc.geom::geometry) as longitude, ST_Y(pc.geom::geometry) as latitude
      FROM product_companies pc
      LEFT JOIN media m ON pc.id = m.model_id AND m.collection_name = 'logo'
      LEFT JOIN map_communes mc ON pc.commune_id = mc.id
      LEFT JOIN map_districts md ON mc.district_id = md.id
      WHERE pc.id = @id
    ''', substitutionValues: {
      'id': id,
    });

    if (companyResult.isNotEmpty) {
      final row = companyResult[0];
      String? logoUrl;
      if (row[8] != null && row[9] != null) {
        logoUrl = 'https://ocop.bentre.gov.vn/storage/images/company/${row[8]}/${row[9]}';
      }
      
      // Lấy danh sách sản phẩm của công ty
      final productsResult = await connection.query('''
        SELECT p.id, p.name, p.rating, pc.name as category_name, m.id as media_id, m.file_name
        FROM products p
        LEFT JOIN product_categories pc ON p.category_id = pc.id
        LEFT JOIN media m ON m.model_id = p.id AND m.model_type = 'App\\Models\\Product\\Product' AND m.collection_name = 'product_featured_image'
        WHERE p.company_id = @companyId
      ''', substitutionValues: {
        'companyId': id,
      });

      List<ProductHome> products = productsResult.map((productRow) {
        String? imageUrl;
        if (productRow[4] != null && productRow[5] != null) {
          String fileName = productRow[5] as String;
          List<String> parts = fileName.split('.');
          if (parts.length > 1) {
            fileName = parts.sublist(0, parts.length - 1).join('.');
          } else {
            fileName = parts[0];
          }
          imageUrl = 'https://ocop.bentre.gov.vn/storage/images/product/${productRow[4]}/conversions/$fileName-md.jpg';
        }
        return ProductHome(
          id: productRow[0] as int,
          name: productRow[1] as String,
          star: productRow[2] as int,
          category: productRow[3] as String,
          img: imageUrl,
        );
      }).toList();

      return Company(
        id: row[0] as int,
        name: row[1] as String,
        introduction: row[2] as String?,
        address: row[3] as String?,
        phoneNumber: row[4] as String?,
        representative: row[5] as String?,
        website: row[6] as String?,
        email: row[7] as String?,
        logoUrl: logoUrl,
        communeName: row[10] as String?,
        districtName: row[11] as String?,
        latitude: row[13] as double?,
        longitude: row[12] as double?,
        products: products,
      );
    }
    return null;
  } catch (e) {
    print('Lỗi khi truy vấn chi tiết công ty: $e');
    return null;
  }
}

Future<List<Company>> getAllCompanies() async {
  try {
    final result = await connection.query('''
      SELECT 
        pc.id, 
        pc.name, 
        m.id as media_id, 
        m.file_name, 
        pt.name as type_name,
        mc.name as commune_name,
        md.name as district_name
      FROM product_companies pc
      LEFT JOIN media m ON pc.id = m.model_id AND m.collection_name = 'logo'
      LEFT JOIN product_types pt ON pc.type_id = pt.id
      LEFT JOIN map_communes mc ON pc.commune_id = mc.id
      LEFT JOIN map_districts md ON mc.district_id = md.id
      ORDER BY pc.name
    ''');

    return result.map((row) {
      String? logoUrl;
      if (row[2] != null && row[3] != null) {
        logoUrl = 'https://ocop.bentre.gov.vn/storage/images/company/${row[2]}/${row[3]}';
      }
      return Company(
        id: row[0] as int,
        name: row[1] as String,
        logoUrl: logoUrl,
        typeName: row[4] as String?,
        communeName: row[5] as String?,
        districtName: row[6] as String?,
      );
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn tất cả công ty: $e');
    return [];
  }
}

Future<Map<String, int>> getCompanyTypeCounts() async {
  try {
    final result = await connection.query('''
      SELECT 
        COALESCE(pt.name, 'Không xác định') AS type_name,
        COUNT(pc.id) AS company_count
      FROM 
        product_companies pc
      LEFT JOIN 
        product_types pt ON pc.type_id = pt.id
      GROUP BY 
        pt.name
      ORDER BY 
        company_count DESC
    ''');

    Map<String, int> groupedCompanyTypes = {};

    for (final row in result) {
      String typeName = row[0] as String;
      int count = row[1] as int;
      groupedCompanyTypes[typeName] = count;
    }

    return groupedCompanyTypes;
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu loại hình công ty: $e');
    return {};
  }
}

Future<Map<String, dynamic>> getCompanyDistrictCounts() async {
  try {
    final result = await connection.query('''
      SELECT md.name, COUNT(pc.id) as company_count
      FROM map_districts md
      LEFT JOIN map_communes mc ON md.id = mc.district_id
      LEFT JOIN product_companies pc ON mc.id = pc.commune_id
      GROUP BY md.name
      ORDER BY company_count DESC
    ''');

    Map<String, int> detailedData = {};
    Map<String, int> groupedData = {};

    for (final row in result) {
      String districtName = row[0] as String;
      int count = row[1] as int;
      detailedData[districtName] = count;
      if (count > 0) {
        groupedData[count.toString()] = (groupedData[count.toString()] ?? 0) + 1;
      }
    }

    return {
      'detailed': detailedData,
      'grouped': groupedData,
    };
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu công ty theo huyện: $e');
    return {
      'detailed': {},
      'grouped': {},
    };
  }
}

Future<Map<String, int>> getCompanyStatusCounts() async {
  try {
    final result = await connection.query('''
      SELECT 
        CASE 
          WHEN approved = true THEN 'Đang hoạt động'
          ELSE 'Không hoạt động'
        END AS status,
        COUNT(*) as count
      FROM 
        company_users
      GROUP BY 
        approved
    ''');

    Map<String, int> statusCounts = {
      'Đang hoạt động': 0,
      'Không hoạt động': 0
    };

    for (final row in result) {
      String status = row[0] as String;
      int count = row[1] as int;
      statusCounts[status] = count;
    }

    return statusCounts;
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu trạng thái công ty: $e');
    return {
      'Đang hoạt động': 0,
      'Không hoạt động': 0
    };
  }
}

}