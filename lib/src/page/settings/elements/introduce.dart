import 'package:flutter/material.dart';
import 'package:ocop/src/page/elements/logo.dart';

class Introduce extends StatelessWidget {
  final List<Text> text = [
    const Text(
      "          OCOP là chương trình trọng tâm phát triển kinh tế khu vực nông thôn theo hướng phát huy nội lực và gia tăng giá trị; là giải pháp và nhiệm vụ quan trọng trong thực hiện Chương trình mục tiêu quốc gia xây dựng nông thôn mới giai đoạn 2021-2025. Phát triển sản phẩm OCOP nhằm khơi dậy tiềm năng, lợi thế khu vực nông thôn, nâng cao thu nhập cho người dân; tiếp tục cơ cấu lại ngành nông nghiệp gắn với phát triển tiểu thủ công nghiệp, ngành nghề, dịch vụ và du lịch nông thôn; thúc đẩy kinh tế nông thôn phát triển bền vững, trên cơ sở tăng cường ứng dụng khoa học và công nghệ, chuyển đổi số, bảo tồn các giá trị văn hóa, quản lý tài nguyên, bảo tồn đa dạng sinh học, cảnh quan và môi trường... góp phần xây dựng nông thôn mới đi vào chiều sâu, hiệu quả và bền vững.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Phát huy vai trò của hệ thống chính trị, các ngành, các cấp, đặc biệt là cấp xã trong triển khai Chương trình OCOP, trong đó Nhà nước giữ vai trò kiến tạo, ban hành cơ chế, chính sách thực hiện định hướng phát triển trục sản phẩm đặc sản địa phương, tạo các vùng nguyên liệu để sản xuất hàng hoá, phát triển dịch vụ; tăng cường quản lý và giám sát tiêu chuẩn, chất lượng sản phẩm, an toàn thực phẩm; hỗ trợ tín dụng, đào tạo, tập huấn, hướng dẫn kỹ thuật, ứng dụng khoa học công nghệ; xây dựng, bảo vệ và phát triển thương hiệu, xác lập quyền sở hữu trí tuệ, xúc tiến thương mại và quảng bá sản phẩm OCOP.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Phấn đấu đến năm 2025, toàn tỉnh có ít nhất 200 sản phẩm OCOP đạt tiêu chuẩn từ 3 sao trở lên, trong đó có 30 sản phẩm đạt 5 sao (hoặc tiềm năng 5 sao); Nâng cấp ít nhất 20% sản phẩm OCOP đã được đánh giá, phân hạng; Ưu tiên phát triển đối với các chủ thể là hợp tác xã, doanh nghiệp nhỏ và vừa, trong đó phấn đấu ít nhất có 20% chủ thể OCOP là hợp tác xã; Có ít nhất 10% chủ thể làng nghề có sản phẩm OCOP được công nhận, góp phần bảo tồn và phát triển làng nghề truyền thống của địa phương; 100% cán bộ phụ trách về OCOP các cấp huyện, xã; doanh nghiệp, hợp tác xã, tổ hợp tác, hộ sản xuất có đăng ký kinh doanh tham gia Chương trình được đào tạo, tập huấn, bồi dưỡng kiến thức các chuyên đề thuộc Chương trình OCOP; Đối với nhóm sản phẩm dịch vụ du lịch cộng đồng và điểm du lịch, phấn đấu có ít nhất 05 sản phẩm được công nhận sản phẩm OCOP đạt từ 3 sao trở lên.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Sản phẩm tham gia bao gồm các sản phẩm hàng hóa và dịch vụ du lịch có nguồn gốc địa phương, có đặc trưng về giá trị văn hóa, lợi thế bản địa; đặc biệt là các sản phẩm đặc sản vùng miền, làng nghề, dịch vụ du lịch dựa trên các thế mạnh, lợi thế về điều kiện tự nhiên, nguồn nguyên liệu, tri thức và văn hóa bản địa. Được chia theo 6 nhóm là thực phẩm; đồ uống; dược liệu và sản phẩm từ dược liệu; hàng thủ công mỹ nghệ; sinh vật cảnh; dịch vụ du lịch cộng đồng, du lịch sinh thái và điểm du lịch.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Để đạt mục tiêu đề ra, UBND tỉnh yêu cầu các sở, ban, ngành và địa phương cần tập trung thực hiện một số nội dung và nhiệm vụ trọng tâm như kiện toàn hệ thống quản lý, điều hành thực hiện Chương trình OCOP; tổ chức sản xuất gắn với phát triên vùng nguyên liệu đặc trưng; chuẩn hóa quy trình, tiêu chuẩn và phát triên sản phẩm OCOP theo chuỗi giá trị, phù hợp với lợi thế về điều kiện sản xuất và yêu cầu thị trường; nâng cao năng lực và hiệu quả hoạt động cho các chủ thể; quảng bá, xúc tiến thương mại, kết nối cung - cầu; xây dựng, hoàn thiện hệ thống quản lý, giám sát; tăng cường chuyên đổi số trong Chương trình OCOP.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Tiếp tục đẩy mạnh công tác truyền thông, nâng cao nhận thức thường xuyên, liên tục thông qua các phương tiện thông tin đại chúng từ cấp tỉnh đến cấp xã, ấp; gắn kết và lồng ghép với hoạt động tuyên truyền trong xây dựng nông thôn mới. Khuyến khích xây dựng các gói combo quà tặng, quà lưu niệm sản phẩm OCOP.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Đẩy mạnh hỗ trợ công tác đào tạo, tập huấn nhằm nâng cao năng lực về quản trị, marketing cho các bộ quản lý, điều hành của các doanh nghiệp, hợp tác xã, các cơ sở, hộ sản xuất. Nâng cao năng lực đội ngũ cán bộ triển khai Chương trình OCOP và chất lượng công tác đánh giá, phân hạng sản phẩm OCOP cấp tỉnh, huyện.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    ),
    const Text(
      "         Đẩy mạnh ứng dụng khoa học công nghệ, đổi mới, hoàn thiện công nghệ chế biến quy mô nhỏ và vừa, đặc biệt là các sản phẩm OCOP đã được công nhận. Hỗ trợ chuyển giao ứng dụng công nghệ, chuyển đổi số trong sản xuất, kết nối thị trường, truy xuất nguồn gốc, nhất là ứng dụng công nghệ thông tin; khoa học xã hội và nhân văn trong phát triển sản phẩm OCOP gắn với du lịch nông thôn, bảo tồn giá trị văn hóa bản địa.",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.left, // Căn trái văn bản
    )
  ];

  Introduce({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduce'), // Thêm title cho AppBar
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Căn trái toàn bộ Column
            children: <Widget>[
              const Text(
                "Cập nhật lần cuối: ",
                style: TextStyle(
                  fontSize: 10,
                ),
                textAlign: TextAlign.left, // Căn trái văn bản
              ),
              const SizedBox(height: 20),
              ...text, // Hiển thị các Text widgets ở đây
              const SizedBox(height: 20),
              const Logo(),
            ],
          ),
        ],
      ),
    );
  }
}
