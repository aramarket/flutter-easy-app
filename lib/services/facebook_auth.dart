// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// class FacebookUserData {
//   final String? name;
//   final String? profilePicUrl;
//   final String? email;
//   final LoginStatus status;
//
//   FacebookUserData({
//     this.name,
//     this.profilePicUrl,
//     this.email,
//     required this.status,
//   });
// }
//
// class FacebookAuthLogin {
//   static Future<FacebookUserData> facebookLogin() async {
//     print("FaceBook method called");
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//
//       if (result.status == LoginStatus.success) {
//         final AccessToken accessToken = result.accessToken!;
//         final userData = await FacebookAuth.instance.getUserData();
//
//         // Extracting user information
//         final String? name = userData['name'];
//         final String? profilePicUrl = userData['picture']['data']['url'];
//         final String? email = userData['email'];
//
//         // print("User Name: $name");
//         // print("Profile Picture URL: $profilePicUrl");
//         // print("Email Address: $email");
//         // print(LoginStatus.success);
//
//         // Returning user data
//         return FacebookUserData(
//           name: name,
//           profilePicUrl: profilePicUrl,
//           email: email,
//           status: LoginStatus.success,
//         );
//       } else {
//         print("Login status: ${result.status}");
//         print("Login message: ${result.message}");
//
//         // Returning user data with error status
//         return FacebookUserData(
//           status: result.status,
//         );
//       }
//     } catch (error) {
//       print("Error: $error");
//
//       // Returning user data with error status
//       return FacebookUserData(
//         status: LoginStatus.failed,
//       );
//     }
//   }
// }
