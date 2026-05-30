import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/home_controller.dart';
import 'booking_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'car_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  final HomeController controller = Get.put(HomeController());

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const HomePage(),
      const MyBookingsScreen(),
      const FavoritesScreen(),
       ProfileScreen(),
    ];
  }

  Widget buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {

    final bool isSelected = currentIndex == index;

    return GestureDetector(

      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 300),

        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 0,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          gradient: isSelected
              ? const LinearGradient(
            colors: [
              Color(0xff2563EB),
              Color(0xff1D4ED8),
            ],
          )
              : null,

          borderRadius: BorderRadius.circular(30),
        ),

        child: Row(
          children: [

            Icon(
              icon,
              color: Colors.white,
              size: 27,
            ),

            if (isSelected) ...[

              const SizedBox(width: 8),

              Text(
                label,

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff0F172A),

      body: pages[currentIndex],

      bottomNavigationBar: Container(

        margin: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 18,
        ),

        height: 78,

        decoration: BoxDecoration(

          gradient: const LinearGradient(
            colors: [
              Color(0xff1E3A8A),
              Color(0xff2563EB),
            ],
          ),

          borderRadius: BorderRadius.circular(40),

          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            buildNavItem(
              icon: Icons.home_rounded,
              label: "Home",
              index: 0,
            ),

            buildNavItem(
              icon: Icons.calendar_month_rounded,
              label: "Booking",
              index: 1,
            ),

            buildNavItem(
              icon: Icons.favorite_rounded,
              label: "Favorite",
              index: 2,
            ),

            buildNavItem(
              icon: Icons.person_rounded,
              label: "Profile",
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final HomeController controller = Get.find<HomeController>();

  final supabase = Supabase.instance.client;

  List favoriteCars = [];

  String searchText = "";

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id);

    setState(() {
      favoriteCars = data;
    });
  }

  bool isFavorite(String carName) {

    return favoriteCars.any(
          (fav) => fav['car_name'] == carName,
    );
  }

  Future<void> toggleFavorite(car) async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    final existing = await supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('car_name', car.name);

    if (existing.isNotEmpty) {

      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('car_name', car.name);

      Get.snackbar(

        "Removed",
        "${car.name} removed from favorites",

        snackPosition: SnackPosition.TOP,

        backgroundColor: Colors.red.shade400,

        colorText: Colors.white,

        margin: const EdgeInsets.all(15),

        borderRadius: 18,

        duration: const Duration(seconds: 2),

        icon: const Icon(
          Icons.favorite_border,
          color: Colors.white,
        ),

        shouldIconPulse: true,

        forwardAnimationCurve: Curves.easeOutBack,
      );

    } else {

      await supabase.from('favorites').insert({

        'user_id': user.id,
        'car_name': car.name,
        'brand': car.brand,
        'image': car.image,
        'price_per_day': car.pricePerDay,
        'fuel_type': car.fuelType,
        'transmission': car.transmission,
        'location': car.location,
      });

      Get.snackbar(

        "Success",
        "${car.name} added to favorites",

        snackPosition: SnackPosition.TOP,

        backgroundColor: Colors.green,

        colorText: Colors.white,

        margin: const EdgeInsets.all(15),

        borderRadius: 18,

        duration: const Duration(seconds: 2),

        icon: const Icon(
          Icons.favorite,
          color: Colors.white,
        ),

        shouldIconPulse: true,

        forwardAnimationCurve: Curves.easeOutBack,
      );
    }

    fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF1F5F9),

      body: Obx(() {

        if (controller.isLoading.value) {

          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final filteredCars = controller.cars.where((car) {

          final query = searchText.toLowerCase();

          return car.name.toLowerCase().contains(query) ||
              car.brand.toLowerCase().contains(query);

        }).toList();

        return SafeArea(

          child: Column(
            children: [

              Container(

                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  20,
                  15,
                  20,
                  22,
                ),

                decoration: const BoxDecoration(

                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff1D4ED8),
                      Color(0xff2563EB),
                      Color(0xff3B82F6),
                    ],
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: const [

                            Text(
                              "Iftiinshe Cars",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 31,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Find your perfect ride",

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        Container(

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color:
                            Colors.white24,

                            borderRadius:
                            BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Container(

                      height: 58,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.08),

                            blurRadius: 15,

                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: TextField(

                        onChanged: (value) {

                          setState(() {
                            searchText = value;
                          });
                        },

                        decoration: InputDecoration(

                          border: InputBorder.none,

                          hintText:
                          "Search by name or brand",

                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),

                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xff2563EB),
                            size: 28,
                          ),

                          suffixIcon: Container(

                            margin: const EdgeInsets.all(8),

                            decoration: BoxDecoration(
                              color:
                              const Color(0xff2563EB),

                              borderRadius:
                              BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,

                      children: [

                        simpleIcon(
                          Icons.workspace_premium_rounded,
                          "Luxury",
                        ),

                        simpleIcon(
                          Icons.flash_on_rounded,
                          "Fast",
                        ),

                        simpleIcon(
                          Icons.shield_rounded,
                          "Safe",
                        ),

                        simpleIcon(
                          Icons.local_gas_station_rounded,
                          "Fuel",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  12,
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: const [

                    Text(
                      "Available Cars",

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F172A),
                      ),
                    ),

                    Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xff2563EB),
                    ),
                  ],
                ),
              ),

              Expanded(

                child: filteredCars.isEmpty

                    ? const Center(
                  child: Text(
                    "No Cars Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )

                    : ListView.builder(

                  physics:
                  const BouncingScrollPhysics(),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount: filteredCars.length,

                  itemBuilder: (context, index) {

                    final car = filteredCars[index];

                    final favorite =
                    isFavorite(car.name);

                    return GestureDetector(

                      onTap: () {
                        Get.to(
                              () =>
                              CarDetailsScreen(car: car),
                        );
                      },

                      child: Container(

                        margin:
                        const EdgeInsets.only(bottom: 24),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(28),

                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.06),

                              blurRadius: 18,

                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Stack(
                              children: [

                                ClipRRect(

                                  borderRadius:
                                  const BorderRadius.only(
                                    topLeft:
                                    Radius.circular(28),

                                    topRight:
                                    Radius.circular(28),
                                  ),

                                  child: Image.network(
                                    car.image,

                                    height: 220,

                                    width: double.infinity,

                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Positioned(
                                  top: 15,
                                  right: 15,

                                  child: GestureDetector(

                                    onTap: () {
                                      toggleFavorite(car);
                                    },

                                    child: Container(

                                      padding:
                                      const EdgeInsets.all(
                                          10),

                                      decoration:
                                      BoxDecoration(
                                        color: Colors.white,

                                        borderRadius:
                                        BorderRadius
                                            .circular(16),
                                      ),

                                      child: Icon(
                                        favorite
                                            ? Icons.favorite
                                            : Icons
                                            .favorite_border,

                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  left: 15,
                                  bottom: 15,

                                  child: Container(

                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),

                                    decoration: BoxDecoration(

                                      gradient:
                                      const LinearGradient(
                                        colors: [
                                          Color(0xff2563EB),
                                          Color(0xff1D4ED8),
                                        ],
                                      ),

                                      borderRadius:
                                      BorderRadius.circular(
                                          16),
                                    ),

                                    child: Text(
                                      "\$${car.pricePerDay} / day",

                                      style:
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding:
                              const EdgeInsets.all(18),

                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    car.name,

                                    style:
                                    const TextStyle(
                                      fontSize: 24,
                                      fontWeight:
                                      FontWeight.bold,
                                      color:
                                      Color(0xff0F172A),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    car.brand,

                                    style:
                                    const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  Row(
                                    children: [

                                      infoBox(
                                        Icons
                                            .local_gas_station_rounded,

                                        car.fuelType,
                                      ),

                                      const SizedBox(width: 10),

                                      infoBox(
                                        Icons.settings_rounded,
                                        car.transmission,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),

                                      const SizedBox(width: 5),

                                      Text(
                                        car.location,

                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget simpleIcon(
      IconData icon,
      String text,
      ) {

    return Column(
      children: [

        Container(

          width: 58,
          height: 58,

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(0.08),

                blurRadius: 10,
              ),
            ],
          ),

          child: Icon(
            icon,

            color: const Color(0xff2563EB),

            size: 25,
          ),
        ),

        const SizedBox(height: 7),

        SizedBox(

          width: 60,

          child: Text(
            text,

            overflow: TextOverflow.ellipsis,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget infoBox(
      IconData icon,
      String text,
      ) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),

        borderRadius:
        BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 18,
            color: const Color(0xff2563EB),
          ),

          const SizedBox(width: 6),

          Text(
            text,

            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}