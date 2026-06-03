import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/login_screen.dart';
import 'manage_cars_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_users_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final supabase = Supabase.instance.client;

  int totalCars = 0;
  int totalUsers = 0;
  int totalBookings = 0;
  int pendingBookings = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final cars = await supabase.from('cars').select();
      final users = await supabase.from('profiles').select();
      final bookings = await supabase.from('bookings').select();

      final pending = bookings
          .where((e) =>
              (e['status'] ?? '').toString().toLowerCase() ==
              'pending')
          .toList();

      setState(() {
        totalCars = cars.length;
        totalUsers = users.length;
        totalBookings = bookings.length;
        pendingBookings = pending.length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Dashboard error: $e");
      setState(() => isLoading = false);
    }
  }

  Widget dashboardCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget menuTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ❌ FIX: removed const
            Get.offAll(() => LoginScreen());
          },
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.35,
                    children: [
                      dashboardCard(
                          "Cars", "$totalCars", Icons.directions_car),
                      dashboardCard("Users", "$totalUsers", Icons.people),
                      dashboardCard("Bookings", "$totalBookings",
                          Icons.calendar_month),
                      dashboardCard("Pending", "$pendingBookings",
                          Icons.pending_actions),
                    ],
                  ),

                  const SizedBox(height: 25),

                  menuTile("Manage Cars", Icons.directions_car, () {
                    Get.to(() => const ManageCarsScreen());
                  }),

                  menuTile("Manage Bookings", Icons.book_online, () {
                    Get.to(() => const ManageBookingsScreen());
                  }),

                  menuTile("Manage Users", Icons.people, () {
                    Get.to(() => const ManageUsersScreen());
                  }),
                ],
              ),
            ),
    );
  }
}