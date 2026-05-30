import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final supabase = SupabaseService.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "Create Account",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: name,
              style: const TextStyle(
                fontSize: 22,
              ),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(
                  fontSize: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: email,
              style: const TextStyle(
                fontSize: 22,
              ),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(
                  fontSize: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: password,
              obscureText: true,
              style: const TextStyle(
                fontSize: 22,
              ),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(
                  fontSize: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: () async {
                  try {

                    final response = await supabase.auth.signUp(
                      email: email.text.trim(),
                      password: password.text.trim(),
                      data: {
                        "name": name.text.trim(),
                      },
                    );

                    final user = response.user;

                    if (user != null) {
                      await supabase.from('profiles').insert({
                        'id': user.id,
                        'name': name.text.trim(),
                        'email': email.text.trim(),
                        'phone': '',
                        'image': '',
                      });
                    }

                    Get.snackbar(
                      "Success",
                      "Account created successfully",
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    Get.offAll(() => LoginScreen());

                  } catch (e) {

                    Get.snackbar(
                      "Error",
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );

                  }
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Get.off(() => LoginScreen());
              },
              child: const Text(
                "Already have an account?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}