
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/db_constants.dart';

class CategoryModel {
  String? id;
  String? name;
  String? slug;
  String? permalink;
  String? image;
  String? parentId;

  CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.image,
    this.parentId,
  });

  //Empty Helper Function
  static CategoryModel empty() => CategoryModel();

  //Convert Model data to json so that you can upload data to firebase
  Map<String, dynamic> toJson() {
    return {
      CategoryFieldName.id: id,
      CategoryFieldName.name: name,
      CategoryFieldName.slug: slug,
      CategoryFieldName.image: image,
      CategoryFieldName.parentId: parentId,
    };
  }

  // Map JSON to CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final slug = json[CategoryFieldName.slug] ?? '';
    final permalink = '${APIConstant.productCategoryUrl + slug}/';
    return CategoryModel(
      id: json[CategoryFieldName.id].toString(),
      name: (json[CategoryFieldName.name]).replaceAll('&amp;', '&') ?? '',
      slug: slug,
      permalink: permalink,
      image: json[CategoryFieldName.image] != null && json[CategoryFieldName.image].isNotEmpty ? json[CategoryFieldName.image]['src'] : '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CategoryFieldName.id: id,
      CategoryFieldName.name: name,
      CategoryFieldName.slug: slug,
      CategoryFieldName.image: image,
      CategoryFieldName.parentId: parentId,
    };
  }

}