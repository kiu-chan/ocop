class AppPath {
  final List<String> listMapUrl = [
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
  ];
  String mapUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

  List<String> listPaths = [
    'lib/src/assets/geodata/vungDem.geojson',
    'lib/src/assets/geodata/vungLoi.geojson',
  ];
}