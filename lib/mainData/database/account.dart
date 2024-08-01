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

    Future<bool> updateUserInfo(int userId, Map<String, dynamic> newInfo) async {
    try {
      var setClause = <String>[];
      var substitutionValues = <String, dynamic>{};

      if (newInfo.containsKey('name')) {
        setClause.add('name = @name');
        substitutionValues['name'] = newInfo['name'];
      }

      if (newInfo.containsKey('commune_id')) {
        setClause.add('commune_id = @communeId');
        substitutionValues['communeId'] = int.parse(newInfo['commune_id']);
      }

      if (newInfo.containsKey('password')) {
        String hashedPassword = BCrypt.hashpw(newInfo['password'], BCrypt.gensalt());
        setClause.add('password = @password');
        substitutionValues['password'] = hashedPassword;
      }

      if (setClause.isEmpty) {
        return false;
      }

      substitutionValues['userId'] = userId;

      final result = await connection.execute('''
        UPDATE company_users
        SET ${setClause.join(', ')}, updated_at = CURRENT_TIMESTAMP
        WHERE id = @userId
      ''', substitutionValues: substitutionValues);

      return result == 1;
    } catch (e) {
      print('Error updating user info: $e');
      return false;
    }
  }

  Future<bool> verifyUserPassword(int userId, String password) async {
    try {
      final result = await connection.query('''
        SELECT password
        FROM company_users
        WHERE id = @userId
      ''', substitutionValues: {
        'userId': userId,
      });

      if (result.isNotEmpty) {
        String storedHash = result[0][0];
        return BCrypt.checkpw(password, storedHash);
      }
      return false;
    } catch (e) {
      print('Error verifying user password: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCommuneInfo(int communeId) async {
  try {
    final result = await connection.query('''
      SELECT id, name
      FROM commune_users
      WHERE id = @id
    ''', substitutionValues: {
      'id': communeId,
    });

    if (result.isNotEmpty) {
      return {
        'id': result[0][0],
        'name': result[0][1],
      };
    }
    return null;
  } catch (e) {
    print('Error fetching commune info: $e');
    return null;
  }
}
}