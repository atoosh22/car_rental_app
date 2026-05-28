import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/car_model.dart';

class CarService {

  final supabase =
      Supabase.instance.client;

  Future<List<CarModel>> getCars() async {

    final response = await supabase
        .from('cars')
        .select();

    return response
        .map<CarModel>(
          (car) =>
          CarModel.fromJson(car),
    )
        .toList();
  }
}