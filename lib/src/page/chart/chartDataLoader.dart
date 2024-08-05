// chart_data_loader.dart
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class ChartDataLoader {
  final DefaultDatabaseOptions databaseData;

  ChartDataLoader() : databaseData = DefaultDatabaseOptions();

  Future<void> connect() async {
    await databaseData.connect();
  }

  Future<ChartData> loadProductRating() async {
    var groupedRating = await databaseData.getProductRatingCounts();
    return ChartData(
      name: "Biểu đồ thống kê sản phẩm theo số sao",
      title: "sao",
      x_title: "Số sao",
      y_title: "Số lượng sản phẩm",
      data: groupedRating,
    );
  }

  Future<ChartData> loadProductCategory() async {
    var groupedRating = await databaseData.getProductCategoryCounts();
    return ChartData(
      name: "Biểu đồ thống kê sản phẩm theo phân loại",
      title: "",
      x_title: "Phân loại",
      y_title: "Số lượng sản phẩm",
      data: groupedRating,
    );
  }

  Future<ChartData> loadProductCommune() async {
    var communeData = await databaseData.getProductCommuneCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng xã theo số lượng sản phẩm",
      title: "Sản phẩm",
      x_title: "Số lượng sản phẩm",
      y_title: "Số xã",
      data: communeData['grouped'] as Map<String, int>,
      detailedData: communeData['detailed'] as Map<String, int>,
      useDetailedDataForTable: true,
    );
  }

  Future<ChartData> loadProductYear() async {
    var groupedYear = await databaseData.getProductYearCounts();
    return ChartData(
      name: "Biểu đồ thống kê sản phẩm theo năm",
      title: "",
      x_title: "Năm",
      y_title: "Số lượng",
      data: groupedYear,
    );
  }

  Future<ChartData> loadCompanyTypes() async {
    var companyTypeCounts = await databaseData.getCompanyTypeCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng chủ thể OCOP theo loại hình kinh doanh",
      title: "",
      x_title: "Loại hình",
      y_title: "Số lượng",
      data: companyTypeCounts,
    );
  }

  Future<ChartData> loadCompanyDistricts() async {
    var districtData = await databaseData.getCompanyDistrictCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng chủ thể OCOP theo huyện",
      title: "Công ty",
      x_title: "Huyện",
      y_title: "Số lượng",
      data: districtData['detailed'] as Map<String, int>,
    );
  }

  Future<ChartData> loadProductDistrict() async {
    var districtData = await databaseData.getProductDistrictCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng sản phẩm theo huyện",
      title: "Sản phẩm",
      x_title: "Huyện",
      y_title: "Số lượng",
      data: districtData['detailed'] as Map<String, int>,
    );
  }

  Future<ChartData> loadCompanyStatus() async {
    var statusCounts = await databaseData.getCompanyStatusCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng chủ thể OCOP theo trạng thái hoạt động",
      title: "",
      x_title: "Trạng thái",
      y_title: "Số lượng",
      data: statusCounts,
    );
  }

  Future<ChartData> loadTotalProductCount() async {
    int totalCount = await databaseData.getTotalProductCount();
    return ChartData(
      name: "Tổng số lượng hồ sơ OCOP trên hệ thống",
      title: "Hồ sơ OCOP",
      x_title: "Loại",
      y_title: "Số lượng",
      data: {"Tổng số hồ sơ OCOP": totalCount},
    );
  }

  Future<ChartData> loadProductStatusCounts() async {
    var statusCounts = await databaseData.getProductStatusCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng hồ sơ OCOP theo trạng thái",
      title: "",
      x_title: "Trạng thái",
      y_title: "Số lượng",
      data: statusCounts,
    );
  }

  Future<ChartData> loadOcopFileDistrict() async {
    var districtData = await databaseData.getOcopFileDistrictCounts();
    return ChartData(
      name: "Biểu đồ thống kê số lượng hồ sơ OCOP theo huyện",
      title: "Hồ sơ OCOP",
      x_title: "Huyện",
      y_title: "Số lượng",
      data: districtData['detailed'] as Map<String, int>,
    );
  }

  Future<ChartData> loadOcopFileYear() async {
  var yearData = await databaseData.getOcopFileYearCounts();
  return ChartData(
    name: "Biểu đồ thống kê số lượng hồ sơ OCOP đang hoạt động theo năm",
    title: "Hồ sơ OCOP",
    x_title: "Năm",
    y_title: "Số lượng",
    data: yearData,
  );
}
}