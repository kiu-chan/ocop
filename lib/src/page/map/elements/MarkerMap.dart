import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/companiesData.dart';

class MarkerMap extends StatelessWidget {
  final List<ImageData> imageDataList;
  final List<CompanyData> companies;
  
  const MarkerMap({
    super.key, 
    required this.imageDataList, 
    required this.companies
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: _buildMarkers() + _buildCompanyMarkers(),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    for (var imageData in imageDataList) {
      if(imageData.getCheck()) {
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
                      color: Colors.black,
                      width: 1.0,
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
    }
    return markers;
  }

  List<Marker> _buildCompanyMarkers() {
    return companies.map((company) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: company.location,
        builder: (ctx) => GestureDetector(
          onTap: () {
            showDialog(
              context: ctx,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(company.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại sản phẩm: ${company.productTypeName}'),
                      Text('Vị trí: ${company.location.latitude}, ${company.location.longitude}'),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 30),
          ),
        ),
      );
    }).toList();
  }
}