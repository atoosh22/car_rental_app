class CarModel {
  final int id;
  final String name;
  final String brand;
  final String image;
  final double pricePerDay;
  final String fuelType;
  final String transmission;
  final String location;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.pricePerDay,
    required this.fuelType,
    required this.transmission,
    required this.location,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      image: json['image'],
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      fuelType: json['fuel_type'],
      transmission: json['transmission'],
      location: json['location'],
    );
  }
}