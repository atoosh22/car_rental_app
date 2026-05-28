import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://hqjgnpnebtzlplfbazap.supabase.co',
      anonKey: 'sb_publishable_EIgGG6WqB6eKNsEtRPXVAg_pomQHjVJ',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}