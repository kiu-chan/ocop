import 'package:postgres/postgres.dart';

class CouncilsDatabase {
  final PostgreSQLConnection connection;

  CouncilsDatabase(this.connection);

  Future<List<Map<String, dynamic>>> getCouncilList() async {
    try {
      final result = await connection.query('''
        SELECT cg.id, cg.title, cg.level, cg.created_at, cg.is_archived, md.name as district_name
        FROM _ocop_evaluation_council_groups cg
        LEFT JOIN map_districts md ON cg.district_id = md.id
        WHERE cg.deleted_at IS NULL
        ORDER BY cg.created_at DESC
      ''');
      
      return result.map((row) => {
        'id': row[0],
        'title': row[1],
        'level': row[2],
        'created_at': row[3],
        'is_archived': row[4],
        'district_name': row[5] ?? 'Không xác định',
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn danh sách hội đồng: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCouncilProducts(int councilId) async {
    try {
      final result = await connection.query('''
        SELECT p.id, p.name, p.rating, p.status, pc.name as category_name,
               e.district_score, e.province_score, e.district_star, e.province_star,
               e.submitted_at, e.in_district_at, e.in_province_at, e.finalize_at
        FROM _ocop_evaluation_council_group_products cgp
        JOIN _ocop_products p ON cgp.product_id = p.id
        LEFT JOIN product_categories pc ON p.category_id = pc.id
        LEFT JOIN _ocop_evaluations e ON p.id = e.product_id
        WHERE cgp.council_group_id = @councilId
        ORDER BY p.name
      ''', substitutionValues: {
        'councilId': councilId,
      });
      
      return result.map((row) => {
        'id': row[0],
        'name': row[1],
        'rating': row[2],
        'status': row[3],
        'category': row[4],
        'district_score': row[5],
        'province_score': row[6],
        'district_star': row[7],
        'province_star': row[8],
        'submitted_at': row[9],
        'in_district_at': row[10],
        'in_province_at': row[11],
        'finalize_at': row[12],
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn sản phẩm của hội đồng: $e');
      return [];
    }
  }

Future<Map<String, dynamic>> getProductEvaluationDetails(int productId, int councilId) async {
  try {
    final result = await connection.query('''
      SELECT 
        e.id as evaluation_id,
        e.district_score,
        e.province_score,
        e.district_star,
        e.province_star,
        cgm.council_user_id
      FROM _ocop_evaluations e
      JOIN _ocop_evaluation_council_group_members cgm ON e.id = cgm.council_group_id
      WHERE e.product_id = @productId AND cgm.council_group_id = @councilId
      LIMIT 1
    ''', substitutionValues: {
      'productId': productId,
      'councilId': councilId,
    });
    
    if (result.isNotEmpty) {
      return {
        'evaluation_id': result[0][0],
        'district_score': result[0][1],
        'province_score': result[0][2],
        'district_star': result[0][3],
        'province_star': result[0][4],
        'council_user_id': result[0][5],
      };
    }
    return {};
  } catch (e) {
    print('Lỗi khi truy vấn chi tiết đánh giá sản phẩm: $e');
    return {};
  }
}

Future<List<Map<String, dynamic>>> getEvaluationPoints(int evaluationId) async {
  try {
    final result = await connection.query('''
      SELECT 
        esp.council_id, 
        cu.name as council_user_name,
        json_agg(json_build_object(
          'criteria_id', esp.score_board_criteria_id, 
          'point', esp.point,
          'comment', ci.name,
          'criteria_name', cr.name,
          'criteria_order', cr.order,
          'group_sub_name', cgs.name,
          'group_sub_id', cgs.id,
          'group_sub_order', cgs.order,
          'group_name', cg.name,
          'group_id', cg.id,
          'group_order', cg.order
        ) ORDER BY cg.order, cgs.order, cr.order) as points,
        SUM(esp.point) as total_points
      FROM _ocop_evaluation_score_board_points esp
      LEFT JOIN _ocop_criteria_items ci ON esp.score_board_criteria_id = ci.id
      LEFT JOIN _ocop_criterias cr ON ci.criteria_id = cr.id
      LEFT JOIN _ocop_criteria_group_subs cgs ON cr.criteria_group_sub_id = cgs.id
      LEFT JOIN _ocop_criteria_groups cg ON cgs.criteria_group_id = cg.id
      LEFT JOIN council_users cu ON esp.council_id = cu.id
      WHERE esp.evaluation_id = @evaluationId
      GROUP BY esp.council_id, cu.name
    ''', substitutionValues: {
      'evaluationId': evaluationId,
    });
    
    return result.map((row) {
      var points = (row[2] as List).map((item) => Map<String, dynamic>.from(item)).toList();
      return {
        'council_id': row[0] as int,
        'council_user_name': row[1] as String,
        'points': points,
        'total_points': row[3] as num,
      };
    }).toList();
  } catch (e) {
    print('Lỗi khi truy vấn điểm đánh giá: $e');
    return [];
  }
}

  Future<int?> getProductEvaluationId(int productId) async {
  try {
    final result = await connection.query('''
      SELECT e.id AS evaluation_id
      FROM _ocop_evaluations e
      JOIN _ocop_products p ON e.product_id = p.id
      WHERE p.id = @productId
      LIMIT 1
    ''', substitutionValues: {
      'productId': productId,
    });
    
    if (result.isNotEmpty) {
      return result[0][0] as int;
    }
    return null;
  } catch (e) {
    print('Lỗi khi truy vấn ID đánh giá sản phẩm: $e');
    return null;
  }
}

Future<List<int>> getCouncilUserIds(int councilGroupId) async {
  try {
    final result = await connection.query('''
      SELECT DISTINCT council_user_id
      FROM _ocop_evaluation_council_group_members
      WHERE council_group_id = @councilGroupId
      ORDER BY council_user_id
    ''', substitutionValues: {
      'councilGroupId': councilGroupId,
    });
    
    return result.map((row) => row[0] as int).toList();
  } catch (e) {
    print('Lỗi khi truy vấn danh sách council_user_id: $e');
    return [];
  }
}

}