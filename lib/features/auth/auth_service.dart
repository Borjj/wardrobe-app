import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Registro con email y contraseña
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
  }) async {
    // Creamos el usuario en Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username}, // Metadata adicional
    );

    // Si el registro fue exitoso, creamos el perfil en la tabla profiles
    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'display_name': username,
      });
    }

    return response;
  }

  // Login con email y contraseña
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  // Stream que escucha cambios de sesión (login/logout)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}