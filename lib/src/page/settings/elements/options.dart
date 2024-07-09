import 'package:flutter/material.dart';

class Options extends StatefulWidget {
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
                padding: const EdgeInsets.all(5.0),
                // color: Colors.white,
                
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0), // Bo tròn viền
                      ),
                      child: InkWell(
                        onTap: () {
                          // xu ly su kien
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => const EditProfilePage())
                          // );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0), // Bo tròn viền
                                    color: const Color.fromRGBO(77, 210, 255, 0.3), // Màu nền
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 20.0,
                                    color: Color.fromRGBO(77, 210, 255, 1),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Container(
                                  child: const Text(
                                    'Profile',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              width: 25.0,
                              height: 25.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0), // Bo tròn viền
                                // color: Color.fromRGBO(211, 211, 211, 0.5), // Màu nền
                              ),
                              child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12.0,
                                  color: Color.fromRGBO(77, 210, 255, 1)
                              ),
                            )
                          ],
                        ),
                      ),
                    ),             // edit data
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0), // Bo tròn viền
                      ),
                      child: InkWell(
                        onTap: () {
                          // xu ly su kien
                          // showDialog(
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return const AboutPage(); // Sử dụng CustomDialog ở đây
                          //   },
                          // );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0), // Bo tròn viền
                                    color: const Color.fromRGBO(0, 230, 142, 0.3), // Màu nền
                                  ),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20.0,
                                    color: Color.fromRGBO(0, 230, 142, 1),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Container(
                                  child: const Text(
                                    'About Us',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              width: 25.0,
                              height: 25.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0), // Bo tròn viền
                                // color: Color.fromRGBO(0, 230, 142, 0.3), // Màu nền
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 12.0,
                                color: Color.fromRGBO(0, 230, 142, 1),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0), // Bo tròn viền
                      ),
                      child: InkWell(
                        onTap: () {
                          // xu ly su kien
                          // showDialog(
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return const LogoutAlert(); // Sử dụng CustomDialog ở đây
                          //   },
                          // );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0), // Bo tròn viền
                                    color: const Color.fromRGBO(233, 22, 64, 0.3), // Màu nền
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    size: 20.0,
                                    color: Color.fromRGBO(233, 22, 64, 1),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Container(
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              width: 25.0,
                              height: 25.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0), // Bo tròn viền
                                // color: Color.fromRGBO(211, 211, 211, 0.5), // Màu nền
                              ),
                              child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12.0,
                                  color: Color.fromRGBO(233, 22, 64, 1)
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),);
  }
}