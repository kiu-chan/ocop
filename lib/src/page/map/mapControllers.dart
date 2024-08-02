import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';
import 'package:ocop/src/data/map/areaData.dart';
import 'package:ocop/src/data/map/companiesData.dart';

class MapControllers {
  double currentZoom = 10.38;
  
  void location(MapController mapController, LatLng mapLat) {
    mapController.move(mapLat, currentZoom);
  }

  void zoomIn(MapController mapController) {
    double zoomFactor = 1.1;
    double newZoom = (mapController.zoom * zoomFactor).clamp(1.0, 18.0);
    mapController.move(mapController.center, newZoom);
  }

  void zoomOut(MapController mapController) {
    double zoomFactor = 0.9;
    double newZoom = (mapController.zoom * zoomFactor).clamp(1.0, 18.0);
    mapController.move(mapController.center, newZoom);
  }

  void handleMapTap(LatLng tappedPoint, List<AreaData> communes, Function showCommuneInfo) {
    print("Tapped point: $tappedPoint");
    for (var commune in communes) {
      if (commune.isVisible) {
        for (var polygon in commune.polygons) {
          if (_isPointInPolygon(tappedPoint, polygon)) {
            print("Found commune: ${commune.id}");
            showCommuneInfo(commune);
            return;
          }
        }
      }
    }
    print("No commune found at tapped point");
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    var isInside = false;
    var j = polygon.length - 1;
    for (var i = 0; i < polygon.length; i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) /
                  (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
  }

  void changeMapSource(int mapValue, List<String> listMapUrl, Function(String) updateMapUrl) {
    String newMapUrl = listMapUrl[mapValue];
    updateMapUrl(newMapUrl);
  }

  void setStateProduct(ImageData imageData, Function updateState) {
    imageData.setCheck();
    updateState();
  }

  void setPolygonData(MapData mapData, Function updateState) {
    mapData.setCheck();
    updateState();
  }

  void filterCompanies(List<String> selectedTypes, List<CompanyData> allCompanies, Function updateFilteredCompanies) {
    if (selectedTypes.isEmpty) {
      updateFilteredCompanies([]);
    } else {
      var filtered = allCompanies.where((company) => 
        selectedTypes.contains(company.productTypeName)).toList();
      updateFilteredCompanies(filtered);
    }
  }

  void filterAreas(List<int> selectedIds, List<AreaData> areas, bool showArea, Function updateState) {
    for (var area in areas) {
      area.isVisible = showArea && selectedIds.contains(area.id);
    }
    updateState();
  }

  void toggleAreaVisibility(bool value, List<AreaData> areas, Set<int> selectedIds, Function updateState) {
    for (var area in areas) {
      area.isVisible = value && selectedIds.contains(area.id);
    }
    updateState();
  }
}