import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../features/authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../../../features/personalization/models/user_model.dart';
import '../../../../utils/cache/cache.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/local_storage_constants.dart';


class WooCustomersRepository extends GetxController {
  static WooCustomersRepository get instance => Get.find();

  final Box _cacheBox = Hive.box(CacheConstants.customerBox); // Hive storage
  final double cacheExpiryTimeInDays = APIConstant.customerCacheTime;

  // Fetch customer by id it gives single user
  Future<CustomerModel> fetchCustomerById(String customerId) async {
    final String cacheKey = 'fetch_customer_by_id_$customerId';

    // Check cache before making API request
    if (_cacheBox.containsKey(cacheKey) && CacheHelper.isCacheValid(cacheBox: _cacheBox, cacheKey: cacheKey, expiryTimeInDays: cacheExpiryTimeInDays)) {
      final cachedData = _cacheBox.get(cacheKey);
      return CustomerModel.fromJson(json.decode(cachedData));
    }

    try {
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooCustomersApiPath+customerId,
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );
      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> customerJson = json.decode(response.body);
        final CustomerModel customer = CustomerModel.fromJson(customerJson);
        // Store data in cache with timestamp
        _cacheBox.put(cacheKey, response.body);
        _cacheBox.put('${cacheKey}_time', DateTime.now().millisecondsSinceEpoch);
        return customer;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch user';
      }
    } catch (error) {
      rethrow;
    }
  }

  //Fetch customer by email it give array
  Future<CustomerModel> fetchCustomerByEmail(String email) async {
    try {
      final Map<String, String> queryParams = {
        'email': email,
        'role': 'customer',
      };
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooCustomersApiPath,
        queryParams,
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final List<dynamic> customerJson = json.decode(response.body);
        if(customerJson.isNotEmpty){
          final CustomerModel customer = CustomerModel.fromJson(customerJson.first);
          return customer;
        } else{
          throw 'Customer not found';
        }
      }else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch user';
      }
    } catch (error) {
      rethrow;
    }
  }

  //Fetch customer by Phone
  Future<String> fetchCustomerByPhone(String phone) async {
    try {
      final Map<String, String> queryParams = {
        'phone': phone,
      };
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooCustomersPhonePath,
        queryParams,
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> customerEmailData = json.decode(response.body);
        final String userId = customerEmailData['id'];
        // final String email = customerEmailData['email'];
        return userId;
      } else if(response.statusCode == 404){
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Customer not found';
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch user';
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CustomerModel> updateCustomerById({required String userID, required  Map<String, dynamic> data}) async {
    try {
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooCustomersApiPath + userID,
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.authorization,
        },
        body: jsonEncode(data),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> customerJson = json.decode(response.body);
        final CustomerModel customer = CustomerModel.fromJson(customerJson);
        // Clear cache for this customer
        CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.customerBox);
        // CacheHelper.deleteCacheKey(cacheBoxName: CacheConstants.customerBox, key: 'fetch_customer_by_id_$userID');

        return customer;
      }else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to update user details';
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CustomerModel> deleteCustomerById(String customerId) async {
    try {
      final Map<String, String> queryParams = {
        'force': 'true',
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooCustomersApiPath + customerId,
        queryParams
      );

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.authorization,
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> customerJson = json.decode(response.body);
        final CustomerModel customer = CustomerModel.fromJson(customerJson);
        CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.customerBox);

        return customer;
      }else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to update user details';
      }
    } catch (error) {
      rethrow;
    }
  }

}