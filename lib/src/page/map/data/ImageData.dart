import 'package:latlong2/latlong.dart';


class ImageData {
  final String imagePath;
  final String title;
  final List<LatLng> locations;
  bool checkRender = true;

  ImageData(this.imagePath, this.title, this.locations);

  void setCheck() {
    checkRender =!checkRender;
    print(checkRender);
  }

  bool getCheck() {
    return checkRender;
  }
}