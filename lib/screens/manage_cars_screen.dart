import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageCarsScreen extends StatefulWidget {
  const ManageCarsScreen({super.key});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    try {
      final data = await supabase
          .from('cars')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        cars = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> addCar(Map<String, dynamic> carData) async {
    await supabase.from('cars').insert(carData);
    loadCars();
    showMessage("Car added successfully");
  }

  Future<void> updateCar(String id, Map<String, dynamic> carData) async {
    await supabase.from('cars').update(carData).eq('id', id);
    loadCars();
    showMessage("Car updated successfully");
  }

  Future<void> deleteCar(String id) async {
    await supabase.from('cars').delete().eq('id', id);
    loadCars();
    showMessage("Car deleted successfully");
  }

  void showCarDialog({Map<String, dynamic>? car}) {
    final name = TextEditingController(text: car?['name'] ?? '');
    final brand = TextEditingController(text: car?['brand'] ?? '');
    final price =
    TextEditingController(text: car?['price_per_day']?.toString() ?? '');
    final image = TextEditingController(text: car?['image'] ?? '');
    final mileage =
    TextEditingController(text: car?['mileage']?.toString() ?? '');
    final transmission =
    TextEditingController(text: car?['transmission'] ?? '');
    final fuelType =
    TextEditingController(text: car?['fuel_type'] ?? '');
    final location =
    TextEditingController(text: car?['location'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(car == null ? "Add Car" : "Update Car"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: "Car Name")),
              TextField(controller: brand, decoration: const InputDecoration(labelText: "Brand")),
              TextField(controller: price, decoration: const InputDecoration(labelText: "Price")),
              TextField(controller: mileage, decoration: const InputDecoration(labelText: "Mileage")),
              TextField(controller: transmission, decoration: const InputDecoration(labelText: "Transmission")),
              TextField(controller: fuelType, decoration: const InputDecoration(labelText: "Fuel Type")),
              TextField(controller: location, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: image, decoration: const InputDecoration(labelText: "Image URL")),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () async {
              final carData = {
                'name': name.text,
                'brand': brand.text,
                'price_per_day': double.tryParse(price.text) ?? 0,
                'image': image.text,
                'mileage': mileage.text,
                'transmission': transmission.text,
                'fuel_type': fuelType.text,
                'location': location.text,
              };

              if (car == null) {
                await addCar(carData);
              } else {
                await updateCar(car['id'].toString(), carData);
              }

              if (mounted) Navigator.pop(context);
            },
            child: Text(
              car == null ? "Add" : "Update",
              style: const TextStyle(color: Colors.white), // ✅ WHITE ADDED
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  Widget buildCarCard(Map<String, dynamic> car) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: car['image'] != null && car['image'] != ''
                ? Image.network(
              car['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Icon(Icons.car_rental, size: 60),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['name'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Text(
                  car['brand'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(Icons.speed, "${car['mileage'] ?? '0'} km"),
                    _chip(Icons.settings, car['transmission'] ?? ''),
                    _chip(Icons.local_gas_station, car['fuel_type'] ?? ''),
                    _chip(Icons.location_on, car['location'] ?? ''),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "\$${car['price_per_day']}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () => showCarDialog(car: car),
                        icon: const Icon(Icons.edit, color: Colors.white), // ✅ WHITE ICON
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.white), // ✅ WHITE TEXT
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => deleteCar(car['id'].toString()),
                        icon: const Icon(Icons.delete, color: Colors.white), // ✅ WHITE ICON
                        label: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white), // ✅ WHITE TEXT
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Cars"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cars.length,
        itemBuilder: (_, i) => buildCarCard(cars[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCarDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}