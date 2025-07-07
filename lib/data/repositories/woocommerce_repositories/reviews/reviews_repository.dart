import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../features/shop/models/review_model.dart';
import '../../../../utils/cache/cache.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/local_storage_constants.dart';


class WooReviewsRepository extends GetxController {
  static WooReviewsRepository get instance => Get.find();

  final Box _cacheBox = Hive.box(CacheConstants.productReviewBox); // Hive  storage
  final double cacheExpiryTimeInDays = APIConstant.productCacheTime;

  // Fetch reviews By product id
  Future<List<ReviewModel>> fetchReviewsByProductId({required String productId, required String page}) async {
    final String cacheKey = 'fetch_review_product_id_${productId}_$page';

    // Check cache before making API request
    if (_cacheBox.containsKey(cacheKey) && CacheHelper.isCacheValid(cacheBox: _cacheBox, cacheKey: cacheKey, expiryTimeInDays: cacheExpiryTimeInDays)) {
      final cachedData = _cacheBox.get(cacheKey);
      final List<dynamic> decodedData = json.decode(cachedData) as List<dynamic>;
      return decodedData.map((data) => ReviewModel.fromJson(data as Map<String, dynamic>, isCustomApi: true)).toList();
    }

    try {
      final Map<String, String> queryParams = {
        'product': productId,
        'per_page': '10',
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsReviewImage,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = json.decode(response.body);
        final List<ReviewModel> reviews = reviewsJson.map((json) => ReviewModel.fromJson(json, isCustomApi: true)).toList();
        // Store data in cache with timestamp
        _cacheBox.put(cacheKey, response.body);
        _cacheBox.put('${cacheKey}_time', DateTime.now().millisecondsSinceEpoch);
        return reviews;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw Exception(errorMessage ?? 'Failed to fetch reviews');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Fetch reviews By user id
  Future<List<ReviewModel>> fetchReviewsByUserId({required String customerId, required String page}) async {
    final String cacheKey = 'fetch_review_product_id_${customerId}_$page';

    // Check cache before making API request
    if (_cacheBox.containsKey(cacheKey) && CacheHelper.isCacheValid(cacheBox: _cacheBox, cacheKey: cacheKey, expiryTimeInDays: cacheExpiryTimeInDays)) {
      final cachedData = _cacheBox.get(cacheKey);
      final List<dynamic> decodedData = json.decode(cachedData) as List<dynamic>;
      return decodedData.map((data) => ReviewModel.fromJson(data as Map<String, dynamic>)).toList();
    }

    try {
      final Map<String, String> queryParams = {
        'reviewer': customerId,
        'per_page': '10',
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsReview,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = json.decode(response.body);
        final List<ReviewModel> reviews = reviewsJson.map((json) => ReviewModel.fromJson(json)).toList();
        // Store data in cache with timestamp
        _cacheBox.put(cacheKey, response.body);
        _cacheBox.put('${cacheKey}_time', DateTime.now().millisecondsSinceEpoch);
        return reviews;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw Exception(errorMessage ?? 'Failed to fetch reviews');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Fetch reviews By user id
  Future<List<ReviewModel>> fetchReviewsByUserEmail({required String customerEmail, required String page}) async {
    final String cacheKey = 'fetch_review_product_id_${customerEmail}_$page';

    // Check cache before making API request
    if (_cacheBox.containsKey(cacheKey) && CacheHelper.isCacheValid(cacheBox: _cacheBox, cacheKey: cacheKey, expiryTimeInDays: cacheExpiryTimeInDays)) {
      final cachedData = _cacheBox.get(cacheKey);
      final List<dynamic> decodedData = json.decode(cachedData) as List<dynamic>;
      return decodedData.map((data) => ReviewModel.fromJson(data as Map<String, dynamic>)).toList();
    }

    try {
      final Map<String, String> queryParams = {
        'reviewer_email': customerEmail,
        'per_page': '10',
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsReview,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = json.decode(response.body);
        final List<ReviewModel> reviews = reviewsJson.map((json) => ReviewModel.fromJson(json)).toList();
        // Store data in cache with timestamp
        _cacheBox.put(cacheKey, response.body);
        _cacheBox.put('${cacheKey}_time', DateTime.now().millisecondsSinceEpoch);
        return reviews;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw Exception(errorMessage ?? 'Failed to fetch reviews');
      }
    } catch (error) {
      rethrow;
    }
  }


  // Submit reviews By product id
  Future<ReviewModel> submitReview(ReviewModel review) async {
    try {
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsReview,
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.authorization,
        },
        body: jsonEncode(review.toJson()),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> reviewsJson = json.decode(response.body);
        final ReviewModel reviews = ReviewModel.fromJson(reviewsJson);
        CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.productReviewBox);
        return reviews;
      }else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw Exception(errorMessage ?? 'Failed to create review');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Submit Bulk reviews By product id
  Future<List<ReviewModel>> submitBulkReview({required List<Map<String, dynamic>> createReviews}) async {
    try {
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsBulkReview,
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.authorization,
        },
        body: jsonEncode({
          'create': createReviews,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<ReviewModel> createdReviews = (jsonResponse['create'] as List<dynamic>)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
        CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.productReviewBox);
        CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.orderBox);
        return createdReviews;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['create']?[0]?['error']?['message'];
        throw Exception(errorMessage ?? 'Failed to create reviews');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Delete reviews By review id
  Future<ReviewModel> deleteReview({required int reviewId}) async {
    try {
      final Map<String, String> queryParams = {
        'force': 'true',
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsReview + reviewId.toString(),
        queryParams,
      );
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> reviewsJson = json.decode(response.body);

        final bool deleted = reviewsJson['deleted'] == true;
        final Map<String, dynamic>? previousReviewJson = reviewsJson['previous'];

        if (deleted && previousReviewJson != null) {
          final ReviewModel previousReview = ReviewModel.fromJson(previousReviewJson);
          CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.productReviewBox);
          return previousReview;
        } else {
          throw Exception("Review was not deleted properly.");
        }
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw Exception(errorMessage ?? 'Failed to create reviews');
      }
    } catch (error) {
      rethrow;
    }
  }

  // update reviews By review id
  Future<ReviewModel> updateReview(int reviewId, Map<String, dynamic> reviewData) async {
    try {
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooProductsReview + reviewId.toString(),
      );
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.authorization,
        },
        body: jsonEncode(reviewData),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> updatedReviewsJson = json.decode(response.body);
        final ReviewModel updatedReview = ReviewModel.fromJson(updatedReviewsJson);
        CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.productReviewBox);
        return updatedReview;
      }else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw Exception(errorMessage ?? 'Failed to update reviews');
      }
    } catch (error) {
      rethrow;
    }
  }
}