import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var image = ''.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    name.value = data['name'] ?? '';
    email.value = data['email'] ?? '';
    phone.value = data['phone'] ?? '';
    image.value = data['image'] ?? '';
  }

  Future<void> uploadProfileImage() async {
    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final bytes = await picked.readAsBytes();

      await supabase.storage
          .from('car-listing')
          .uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final url =
      supabase.storage.from('car-listing').getPublicUrl(fileName);

      image.value = url;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('profiles').update({
        'name': newName,
        'phone': newPhone,
        'image': image.value,
      }).eq('id', user.id);

      name.value = newName;
      phone.value = newPhone;

      Get.snackbar("Success", "Profile updated");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}