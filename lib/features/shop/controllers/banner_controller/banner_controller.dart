
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/banners/woo_banners_repositories.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../models/banner_model.dart';

class BannerController extends GetxController {

  //variables
  final isLoading = false.obs;
  final carousalCurrentIndex = 0.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;

  final wooBannersRepositories = Get.put(WooBannersRepositories());

  @override
  void onInit() {
    refreshBanners();
    super.onInit();
  }

  //update page navigational Dots
  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  //fetch banner
  Future<void> getBanners() async {
    try {
      //fetch Banners from data source(firebase, api, etc)
      final allBanners = await wooBannersRepositories.fetchBanners();
      // Filter banners with a non-empty imageUrl
      final banners = allBanners.where((banner) => banner.imageUrl?.isNotEmpty == true).toList();
      //assign banner
      this.banners.assignAll(banners);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error - Banner loading', message: e.toString());
    }
  }

  Future<void> refreshBanners() async {
    try {
      isLoading(true);
      banners.clear(); // Clear existing orders
      await getBanners();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

// fetch banner
// Future<void> fetchBannersLocal() async {
//   try {
//     // Show loader while loading banners
//     isLoading.value = true;
//
//     // Loop through the asset image paths
//     for (String path in assetImagePaths) {
//       // Load the asset image
//       ByteData imageData = await rootBundle.load(path);
//
//       // Convert the ByteData to Uint8List
//       List<int> byteList = imageData.buffer.asUint8List();
//
//       // Convert the byteList to base64 encoded string
//       String base64Image = base64Encode(byteList);
//
//       // Create a BannerModel instance and add it to the banners list
//       banners.add(BannerModel(imageUrl: base64Image));
//     }
//
//     // Hide loader after loading banners
//     isLoading.value = false;
//   } catch (e) {
//     // Handle errors
//     isLoading.value = false;
//     print('=========$e');
//   }
// }
}