import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../wardrobe/screens/wardrobe_screen.dart';
import '../../garment/screens/add_garment_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  
  // Índice de la pestaña activa en el bottom navigation
  int _currentIndex = 0;

  // Pantallas del bottom navigation — las iremos rellenando
  final List<Widget> _screens = [
    const _PlaceholderScreen(label: 'Feed'),
    const WardrobeScreen(),
    const _PlaceholderScreen(label: 'Añadir prenda'),
    const _PlaceholderScreen(label: 'Looks'),
    const ProfileScreen(),
  ];

  Future<void> _logout() async {
    await _authService.logout();
    // El StreamBuilder en main.dart detecta el logout y redirige al login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1825),

      // Barra superior
      appBar: AppBar(
        backgroundColor: const Color(0xFF242235),
        title: const Text(
          'Wardrobe',
          style: TextStyle(
            color: Color(0xFF534AB7),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // Botón de cerrar sesión temporal para testing
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF9996cc)),
            onPressed: _logout,
          ),
        ],
      ),

      // Contenido de la pestaña activa
      body: _screens[_currentIndex],

      // Navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddGarmentScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: const Color(0xFF242235),
        selectedItemColor: const Color(0xFF534AB7),
        unselectedItemColor: const Color(0xFF6e6b99),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            activeIcon: Icon(Icons.checkroom),
            label: 'Armario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Añadir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            activeIcon: Icon(Icons.style),
            label: 'Looks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Placeholder temporal para cada pestaña mientras las desarrollamos
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9996cc),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}