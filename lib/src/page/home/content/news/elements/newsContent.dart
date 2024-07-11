import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/src/page/elements/star.dart';
import 'package:ocop/src/page/elements/logo.dart';

class NewContent extends StatelessWidget {
  final News news;

  const NewContent({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news.name),
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
                      news.name, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      )
                    ),
                    SizedBox(height: 8),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Column(
                        children: [
                          const Text(
                            "Ngày xuất bản",
                            style: TextStyle(
                              fontSize: 10,
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