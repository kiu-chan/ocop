import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';

class AccountDatabase {
  final PostgreSQLConnection connection;

  AccountDatabase(this.connection);
  
  Future<Map<String, dynamic>?> checkUserCredentials(String email, String password) async {
    try {
      final result = await connection.query('''
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

Future<bool> checkUserExists(String email) async {
    try {
      final result = await connection.query(
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

      await connection.query('''
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
}