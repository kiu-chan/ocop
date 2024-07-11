import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/elements/star.dart';
import 'package:ocop/src/page/elements/logo.dart';

class ProductInformation extends StatelessWidget {
  final Product product;

  const ProductInformation({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/src/assets/img/map/img.png',
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    Text(
                      product.name, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      )
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                      ),
                      height: 150,
                      // width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              const Text(
                                "Tên sản phẩm",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  ),
                              ),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  ),
                              )
                          ],),
                          const Row(
                            children: [
                              Text(
                                "số sao đạt:",
                                style:TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  ),
                              ),
                              Star(value: 3),
                          ],),
                          Row(
                            children: [
                              const Text(
                                "Chứng nhận OCOP số: ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  ),
                              ),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  ),
                              )
                          ],),
                          Row(
                            children: [
                              const Text(
                                "Danh mục: ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  ),
                              ),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  ),
                              )
                          ],),
                          Row(
                            children: [
                              const Text(
                                "Sản phẩm",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  ),
                              ),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  ),
                              )
                          ],),
                        ]
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 180,
                      padding: EdgeInsets.all(12),
                      // width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              const Icon(
                                Icons.home_work
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.name,
                              )
                          ],),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.star.toString(),
                              )
                          ],),
                          Row(
                            children: [
                              const Icon(
                                Icons.person
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.name,
                              )
                          ],),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.name,
                              )
                          ],),
                          Row(
                            children: [
                              const Icon(
                                Icons.email
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.name,
                              )
                          ],),
                          Row(
                            children: [
                              const Icon(
                                Icons.language
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.name,
                              )
                          ],),
                        ]
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          const Text(
                            "Câu chuyện sản phẩm",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              ),
                            ),
                          const SizedBox(height: 20,),
                          Container(
                            child: Text(
                              "Dân làng chọn ngày lành tháng tốt làm lễ mời ông Cả về nhận chức cùng lễ vật như: heo, gà, vịt, hoa quả và quan trọng là không thể thiếu rượu. Tuy nhiên các lễ vật này, ông chỉ nhận đầu heo và tờ cử. Nếu như năm nào dân cúng rượu ngon, nếp rặt lên men hàng tháng mới kháp, rượu kháp xong phải ủ lâu ngày trong lòng đất thì Ông mới nhậm. Và năm nào ông Cả nhậm rượu của làng dân cúng ắt năm đó mùa màng trúng to. Sau khi Cả Cọp mất đi, dân mới bầu Cả Non rồi Cả Tiết.Hiện nay, tại Cầu Bà Bồi, ấp Bình An, Xã Châu Bình còn thờ lăng Cả Cọp. Hằng năm vào ngày mùng 7 tháng giêng có lễ cúng khai sơ và mùng 10 tháng 5 âm lịch có lễ cúng ông Cả nhằm nhắc nhở lớp sau nhớ về một thời mỡ cõi khó nhọc của ông cha.",
                              style: TextStyle(
                                fontSize: 20,
                                ),
                              ),
                          )
                        ],
                      ),
                    ),
                    Logo(),
                  ],
                ),
              ),
            ),
        ]
      ),
    );
  }
}