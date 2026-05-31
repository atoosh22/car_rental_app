import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final nameController =
    TextEditingController(text: controller.name.value);

    final phoneController =
    TextEditingController(text: controller.phone.value);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () async {
                    await controller.uploadProfileImage();
                  },
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: controller.image.value.isNotEmpty
                        ? NetworkImage(controller.image.value)
                        : null,
                    child: controller.image.value.isEmpty
                        ? const Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.blueAccent,
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Tap image to change",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              _buildTextField(
                controller: nameController,
                label: "Name",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: phoneController,
                label: "Phone",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: TextEditingController(
                  text: controller.email.value,
                ),
                label: "Email",
                icon: Icons.email_outlined,
                enabled: false,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                    await controller.updateProfile(
                      newName: nameController.text.trim(),
                      newPhone: phoneController.text.trim(),
                    );

                    Get.snackbar(
                      "Success",
                      "Profile updated successfully",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );

                    Get.back();
                  },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}