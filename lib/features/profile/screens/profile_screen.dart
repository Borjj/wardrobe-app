import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1825),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF534AB7)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Cabecera del perfil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    color: const Color(0xFF242235),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFF534AB7),
                          child: Text(
                            _profile?['display_name']?[0].toUpperCase() ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nombre
                        Text(
                          _profile?['display_name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Username
                        Text(
                          '@${_profile?['username'] ?? ''}',
                          style: const TextStyle(
                            color: Color(0xFF9996cc),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Bio
                        if (_profile?['bio'] != null)
                          Text(
                            _profile!['bio'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9996cc),
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Estadísticas básicas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat('Prendas', '0'),
                            _buildDivider(),
                            _buildStat('Looks', '0'),
                            _buildDivider(),
                            _buildStat('Seguidores', '0'),
                            _buildDivider(),
                            _buildStat('Siguiendo', '0'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Botón editar perfil
                        OutlinedButton(
                          onPressed: () {}, // Lo implementamos después
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF534AB7),
                            side: const BorderSide(color: Color(0xFF534AB7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Editar perfil'),
                        ),
                      ],
                    ),
                  ),

                  // Opciones del perfil
                  const SizedBox(height: 16),
                  _buildMenuSection('Cuenta', [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      label: 'Editar perfil',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      label: 'Privacidad',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildMenuSection('App', [
                    _buildMenuItem(
                      icon: Icons.star_outline,
                      label: 'Hazte Premium',
                      onTap: () {},
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF534AB7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Ayuda',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildMenuSection('', [
                    _buildMenuItem(
                      icon: Icons.logout,
                      label: 'Cerrar sesión',
                      onTap: _logout,
                      color: Colors.redAccent,
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Widget de estadística individual
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9996cc),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: const Color(0xFF3d3a6b),
    );
  }

  // Sección de menú con título
  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6e6b99),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF242235),
            border: Border(
              top: BorderSide(color: Color(0xFF3d3a6b)),
              bottom: BorderSide(color: Color(0xFF3d3a6b)),
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  // Item individual del menú
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    final itemColor = color ?? const Color(0xFFc2c0e8);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: itemColor, size: 20),
      title: Text(
        label,
        style: TextStyle(color: itemColor, fontSize: 14),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Color(0xFF6e6b99), size: 20),
    );
  }
}