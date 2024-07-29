import 'package:latlong2/latlong.dart';
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
        pt.name AS product_type_name
      FROM 
        product_companies pc
      JOIN 
        product_types pt ON pc.type_id = pt.id
    ''');

    return result.map((row) {
      final geomText = row[0] as String;
      final coordinates = geomText.split('(')[1].split(')')[0].split(' ');
      return CompanyData(
        location: LatLng(
          double.parse(coordinates[1]),
          double.parse(coordinates[0]),
        ),
        typeId: row[1] as int,
        name: row[2] as String,
        productTypeName: row[3] as String,
      );
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn dữ liệu công ty: $e');
    return []; // Trả về danh sách trống nếu có lỗi
  }
}

}