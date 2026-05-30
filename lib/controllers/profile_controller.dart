import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var image = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
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
    } catch (e) {
      print(e);
    }
  }
}