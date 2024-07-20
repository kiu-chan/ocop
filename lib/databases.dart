import 'package:postgres/postgres.dart';

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

  Future<List<Map<String, dynamic>>> getProducts() async {
    final result = await connection!.query('SELECT * FROM public.products');
    List<Map<String, dynamic>> products = [];

    for (var row in result) {
      products.add({
        'id': row[0],
        'geom': row[1],
        'commune_id': row[2],
        'company_id': row[3],
        'category_id': row[4],
        'group_id': row[5],
        'sub_group_id': row[6],
        'name': row[7],
        'address': row[8],
        'content': row[9],
        'rating': row[10],
        'max_rating': row[11],
        'note': row[12],
        'business_registration_number': row[13],
        'business_registration_recognition_date': row[14],
        'business_registration_expiration_date': row[15],
        'created_at': row[16],
        'updated_at': row[17],
        'deleted_at': row[18],
        'slug': row[19],
        'year': row[20],
        'published_at': row[21],
        'applied_for_certificate_at': row[22],
      });
      print(row[1]);
    }

    return products;
  }

  Future<void> close() async {
    await connection!.close();
    print('Connection closed.');
  }
}
