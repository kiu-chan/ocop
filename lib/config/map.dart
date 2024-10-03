import 'package:latlong2/latlong.dart';

class MapConfig {
  static const double defaultZoom = 10.38;
  static LatLng mapLat = LatLng(10.2417, 106.3748);

  static bool get isOfflineMode => false;
  static bool get showCommunes => false;
  static bool get showDistricts => true;
  static bool get showBorders => false;
  static bool get showProducts => true;

  double getDefaultZoom() {
    return defaultZoom;
  }

  LatLng getDefaultMap() {
    return mapLat;
  }
}
