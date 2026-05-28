import 'package:get/get.dart';

import '../models/car_model.dart';
import '../services/car_service.dart';

class HomeController extends GetxController {

  final CarService carService =
  CarService();

  RxList<CarModel> cars =
      <CarModel>[].obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {

    getCars();

    super.onInit();
  }

  Future<void> getCars() async {

    try {

      isLoading.value = true;

      final data =
      await carService.getCars();

      cars.assignAll(data);

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;

    }
  }
}