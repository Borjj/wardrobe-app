import 'package:supabase_flutter/supabase_flutter.dart';

class GarmentService {
  final _supabase = Supabase.instance.client;

  // Crea una nueva prenda en la base de datos
  Future<Map<String, dynamic>> createGarment({
    required String imageUrl,
    String? imageProcessedUrl,
    required String category,
    required String color,
    String? pattern,
    String? brand,
    String? size,
    String? season,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase.from('garments').insert({
      'user_id': userId,
      'image_url': imageUrl,
      'image_processed_url': imageProcessedUrl,
      'category': category,
      'color': color,
      'pattern': pattern,
      'brand': brand,
      'size': size,
      'season': season,
      'is_active': true,
    }).select().single(); // Devuelve la prenda recién creada

    return response;
  }

  // Obtiene todas las prendas activas del usuario
  Future<List<Map<String, dynamic>>> getGarments() async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('garments')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Actualiza los datos de una prenda existente
  Future<void> updateGarment({
    required String garmentId,
    String? category,
    String? color,
    String? pattern,
    String? brand,
    String? size,
    String? season,
  }) async {
    await _supabase.from('garments').update({
      if (category != null) 'category': category,
      if (color != null) 'color': color,
      if (pattern != null) 'pattern': pattern,
      if (brand != null) 'brand': brand,
      if (size != null) 'size': size,
      if (season != null) 'season': season,
    }).eq('id', garmentId);
  }

  // Marca una prenda como inactiva (soft delete — no borra de la BD)
  Future<void> archiveGarment(String garmentId) async {
    await _supabase
        .from('garments')
        .update({'is_active': false})
        .eq('id', garmentId);
  }

  // Actualiza la fecha de último uso de una prenda
  Future<void> markAsWorn(String garmentId) async {
    await _supabase.from('garments').update({
      'last_worn_at': DateTime.now().toIso8601String(),
    }).eq('id', garmentId);
  }
}