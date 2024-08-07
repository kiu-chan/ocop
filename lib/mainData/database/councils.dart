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

  Future<List<Map<String, dynamic>>> getProductEvaluationDetails(int productId, int councilId) async {
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
      ''', substitutionValues: {
        'productId': productId,
        'councilId': councilId,
      });
      
      return result.map((row) => {
        'evaluation_id': row[0],
        'district_score': row[1],
        'province_score': row[2],
        'district_star': row[3],
        'province_star': row[4],
        'council_user_id': row[5],
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn chi tiết đánh giá sản phẩm: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEvaluationPoints(int councilUserId, int evaluationId) async {
    try {
      final result = await connection.query('''
        SELECT score_board_criteria_id, point
        FROM _ocop_evaluation_score_board_points
        WHERE council_id = @councilUserId AND evaluation_id = @evaluationId
      ''', substitutionValues: {
        'councilUserId': councilUserId,
        'evaluationId': evaluationId,
      });
      
      return result.map((row) => {
        'score_board_criteria_id': row[0],
        'point': row[1],
      }).toList();
    } catch (e) {
      print('Lỗi khi truy vấn điểm đánh giá: $e');
      return [];
    }
  }
}