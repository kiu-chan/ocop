import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:math';

class AccountDatabase {
  final PostgreSQLConnection connection;

  AccountDatabase(this.connection);
  
Future<Map<String, dynamic>?> checkUserCredentials(String email, String password) async {
  try {
    // Kiểm tra trong bảng admins trước
    final adminResult = await connection.query('''
      SELECT id, name, email, password
      FROM admins
      WHERE email = @email
    ''', substitutionValues: {
      'email': email,
    });

    if (adminResult.isNotEmpty) {
      String storedHash = adminResult[0][3];
      if (BCrypt.checkpw(password, storedHash)) {
        return {
          'id': adminResult[0][0],
          'name': adminResult[0][1],
          'email': adminResult[0][2],
          'role': 'admin',
        };
      }
    }

    // Nếu không phải admin, kiểm tra trong bảng company_users
    final userResult = await connection.query('''
      SELECT id, name, email, password, commune_id
      FROM company_users
      WHERE email = @email AND approved = true
    ''', substitutionValues: {
      'email': email,
    });

    if (userResult.isNotEmpty) {
      String storedHash = userResult[0][3];
      if (BCrypt.checkpw(password, storedHash)) {
        return {
          'id': userResult[0][0],
          'name': userResult[0][1],
          'email': userResult[0][2],
          'commune_id': userResult[0][4],
          'role': 'user',
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

Future<String> createPasswordResetToken(String email) async {
  try {
    // Tạo mã code 6 số ngẫu nhiên
    String code = (Random().nextInt(900000) + 100000).toString();
    
    // Mã hóa code
    String hashedCode = BCrypt.hashpw(code, BCrypt.gensalt());

    // Cập nhật hoặc chèn vào database
    await connection.execute('''
      INSERT INTO password_resets (email, token, created_at)
      VALUES (@email, @token, CURRENT_TIMESTAMP)
      ON CONFLICT (email) 
      DO UPDATE SET 
        token = @token, 
        created_at = CURRENT_TIMESTAMP
    ''', substitutionValues: {
      'email': email,
      'token': hashedCode,
    });

    return code; // Trả về code chưa mã hóa để gửi email
  } catch (e) {
    print('Error creating password reset token: $e');
    return '';
  }
}

  Future<bool> verifyPasswordResetToken(String email, String code) async {
    try {
      final result = await connection.query('''
        SELECT token
        FROM password_resets
        WHERE email = @email
        AND token IS NOT NULL
        AND created_at > NOW() - INTERVAL '15 minutes'
        ORDER BY created_at DESC
        LIMIT 1
      ''', substitutionValues: {
        'email': email,
      });

      if (result.isNotEmpty) {
        String storedHash = result[0][0];
        return BCrypt.checkpw(code, storedHash);
      }
      return false;
    } catch (e) {
      print('Error verifying password reset token: $e');
      return false;
    }
  }

Future<bool> resetPassword(String email, String newPassword) async {
  try {
    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    final result = await connection.execute('''
      UPDATE company_users
      SET password = @password
      WHERE email = @email
    ''', substitutionValues: {
      'email': email,
      'password': hashedPassword,
    });

    return result == 1; // Trả về true nếu có một hàng được cập nhật
  } catch (e) {
    print('Error resetting password: $e');
    return false;
  }
}

  Future<int> getRemainingTimeForResetCode(String email) async {
  try {
    final result = await connection.query('''
      SELECT EXTRACT(EPOCH FROM (NOW() - created_at)) as seconds_passed
      FROM password_resets
      WHERE email = @email
      ORDER BY created_at DESC
      LIMIT 1
    ''', substitutionValues: {
      'email': email,
    });

    if (result.isNotEmpty) {
      int secondsPassed = result[0][0].round();
      int remainingTime = 120 - secondsPassed; // 120 seconds = 2 minutes
      return remainingTime > 0 ? remainingTime : 0;
    }
    return 0;
  } catch (e) {
    print('Error getting remaining time for reset code: $e');
    return 0;
  }
}

Future<bool> checkEmailExists(String email) async {
  try {
    final result = await connection.query('''
      SELECT COUNT(*) 
      FROM company_users 
      WHERE email = @email
    ''', substitutionValues: {
      'email': email,
    });

    return (result[0][0] as int) > 0;
  } catch (e) {
    print('Error checking email existence: $e');
    return false;
  }
}
}