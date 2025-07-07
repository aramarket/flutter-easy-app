
import '../../../utils/constants/db_constants.dart';

class BannerModel {
  String? imageUrl;
  final String? targetPageUrl;

  BannerModel({this.imageUrl, this.targetPageUrl});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      imageUrl: json[BannerFieldName.imageUrl] ?? '',
      targetPageUrl: json[BannerFieldName.targetPageUrl] ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      BannerFieldName.imageUrl: imageUrl,
      BannerFieldName.targetPageUrl: targetPageUrl,
    };
  }

}