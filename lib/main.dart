import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase con las credenciales del proyecto
  await Supabase.initialize(
    url: 'https://pvwnvwcxbkizgibwcycw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2d252d2N4YmtpemdpYndjeWN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NTc5MzgsImV4cCI6MjA5MzAzMzkzOH0.kjshlYaZm2mlXImY9BQe62CDUC6zHOUEAMKjX5ycSrk',
  );

  runApp(const MyApp());
}

// Cliente global de Supabase — accesible desde cualquier parte de la app
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wardrobe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF534AB7),
        ),
        useMaterial3: true,
      ),
      // StreamBuilder escucha cambios de sesión en tiempo real
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final session = snapshot.data!.session;
            // Si hay sesión activa, mostramos el home
            if (session != null) {
              return const HomeScreen();
            }
          }
          // Si no hay sesión, mostramos el login
          return const LoginScreen();
        },
      ),
    );
  }
}