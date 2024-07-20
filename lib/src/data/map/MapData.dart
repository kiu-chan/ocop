import 'package:latlong2/latlong.dart';

class MapData {
  final String mapPath;
  final List<LatLng> mapData;
  bool checkRender = true;

  MapData(this.mapPath, this.mapData);

  String getPath() {
    return mapPath;
  }

  // void setMapData(List<LatLng> mapData) {
  //   this.mapData = mapData;
  // }

  List<LatLng>  getMapData() {
    return mapData;
  }

  void setCheck() {
    checkRender =!checkRender;
  }

  bool getCheck() {
    return checkRender;
  }
}
