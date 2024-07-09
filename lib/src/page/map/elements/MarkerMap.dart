import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ocop/src/page/map/data/ImageData.dart';

class MarkerMap extends StatelessWidget {
  final List<ImageData> imageDataList;
  MarkerMap({required this.imageDataList});
  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: _buildMarkers(),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    for (var imageData in imageDataList) {
      if(imageData.getCheck())
      for (var location in imageData.locations) {
        markers.add(
          Marker(
            width: 50.0,
            height: 50.0,
            point: location,
            builder: (ctx) => GestureDetector(
              onTap: () {
                showDialog(
                  context: ctx,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(imageData.title),
                      content: Image.asset(imageData.imagePath),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,  // Màu viền
                    width: 1.0,  // Độ dày viền
                  ),
                  image: DecorationImage(
                    image: AssetImage(imageData.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }
  }