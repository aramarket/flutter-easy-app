import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../../utils/constants/api_constants.dart';

class WhatsappApi extends GetxController {
  static WhatsappApi get instance => Get.find();

  static final String whatsappBaseDomain      = 'graph.facebook.com';
  static final String whatsappApiVersion      = 'v19.0';
  static final String whatsappApiLanguageCode = 'en';

  /// Send OTP via WhatsApp Cloud API
  static Future<bool> sendOtp({required String phoneNumber, required String otp}) async {

    final Uri uri = Uri.https(
      whatsappBaseDomain,
      '/$whatsappApiVersion/${APIConstant.whatsappPhoneNumberId}/messages', // your phone number ID
    );

    final Map<String, dynamic> body = {
      "messaging_product": "whatsapp",
      "to": phoneNumber,
      "type": "template",
      "template": {
        "name": APIConstant.waApiTemplateOtp,
        "language": {"code": whatsappApiLanguageCode},
        "components": [
          {
            "type": "body",
            "parameters": [
              {
                "type": "text",
                "text": otp
              }
            ]
          },
          {
            "type": "button",
            "sub_type": "url",
            "index": 0,
            "parameters": [
              {
                "type": "text",
                "text": otp
              }
            ]
          }
        ]
      }
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${APIConstant.whatsappApiToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        throw Exception(errorJson['error']['message'] ?? 'Failed to send WhatsApp OTP');
      }
    } catch (e) {
      rethrow;
    }
  }
}
