import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  final supabase = Supabase.instance.client;

  List favorites = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {

    final user = supabase.auth.currentUser;

    if (user == null) {

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {

      final data = await supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        favorites = data;
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

    }
  }

  Future<void> removeFavorite(String carName) async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('car_name', carName);

    fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xff2563EB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Favorite Cars",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : favorites.isEmpty
          ? const Center(
        child: Text(
          "No favorite cars",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      )

          : ListView.builder(

        padding: const EdgeInsets.all(14),

        itemCount: favorites.length,

        itemBuilder: (context, index) {

          final car = favorites[index];

          return Container(

            margin: const EdgeInsets.only(bottom: 18),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),

                  child: Image.network(
                    car['image'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          Expanded(
                            child: Text(
                              car['car_name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F172A),
                              ),
                            ),
                          ),

                          IconButton(

                            onPressed: () {
                              removeFavorite(car['car_name']);
                            },

                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        car['brand'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          const Icon(
                            Icons.local_gas_station,
                            size: 18,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 5),

                          Text(car['fuel_type']),

                          const SizedBox(width: 15),

                          const Icon(
                            Icons.settings,
                            size: 18,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 5),

                          Text(car['transmission']),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.red,
                          ),

                          const SizedBox(width: 5),

                          Text(car['location']),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff2563EB),
                              Color(0xff1D4ED8),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Text(
                          "\$${car['price_per_day']}/day",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}