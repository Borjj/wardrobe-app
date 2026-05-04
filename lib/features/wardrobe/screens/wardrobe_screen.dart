import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final _supabase = Supabase.instance.client;
  
  // Lista de prendas cargadas desde Supabase
  List<Map<String, dynamic>> _garments = [];
  bool _isLoading = true;
  
  // Filtros activos
  String? _selectedCategory;
  String? _selectedSeason;

  // Categorías disponibles
  final List<String> _categories = [
    'Todas', 'Tops', 'Pantalones', 'Vestidos', 'Faldas',
    'Chaquetas', 'Abrigos', 'Zapatos', 'Accesorios'
  ];

  // Temporadas disponibles
  final List<String> _seasons = [
    'Todas', 'Primavera', 'Verano', 'Otoño', 'Invierno'
  ];

  @override
  void initState() {
    super.initState();
    _loadGarments(); // Cargamos las prendas al entrar en la pantalla
  }

  Future<void> _loadGarments() async {
    setState(() => _isLoading = true);

    try {
      // Consulta base — solo prendas del usuario actual
      var query = _supabase
          .from('garments')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final data = await query;
      
      // Aplicamos filtros en local si están activos
      List<Map<String, dynamic>> filtered = List<Map<String, dynamic>>.from(data);
      
      if (_selectedCategory != null && _selectedCategory != 'Todas') {
        filtered = filtered
            .where((g) => g['category'] == _selectedCategory)
            .toList();
      }
      
      if (_selectedSeason != null && _selectedSeason != 'Todas') {
        filtered = filtered
            .where((g) => g['season'] == _selectedSeason)
            .toList();
      }

      setState(() {
        _garments = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando el armario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtro de categorías (scroll horizontal)
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat ||
                  (_selectedCategory == null && cat == 'Todas');
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  _loadGarments();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF534AB7)
                        : const Color(0xFF242235),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF534AB7)
                          : const Color(0xFF3d3a6b),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9996cc),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Grid de prendas
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF534AB7),
                  ),
                )
              : _garments.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,       // 3 columnas como Whering
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,  // Ratio vertical para ropa
                      ),
                      itemCount: _garments.length,
                      itemBuilder: (context, index) {
                        return _GarmentCard(garment: _garments[index]);
                      },
                    ),
        ),
      ],
    );
  }

  // Estado vacío cuando el armario no tiene prendas
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.checkroom_outlined,
            size: 64,
            color: Color(0xFF3d3a6b),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu armario está vacío',
            style: TextStyle(
              color: Color(0xFF9996cc),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Añade tu primera prenda',
            style: TextStyle(
              color: Color(0xFF6e6b99),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {}, // Lo conectamos al flujo de añadir prenda
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF534AB7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Añadir prenda'),
          ),
        ],
      ),
    );
  }
}

// Tarjeta individual de prenda en el grid
class _GarmentCard extends StatelessWidget {
  final Map<String, dynamic> garment;
  const _GarmentCard({required this.garment});

  @override
  Widget build(BuildContext context) {
    final imageUrl = garment['image_processed_url'] ?? garment['image_url'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242235),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3d3a6b)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // Placeholder mientras carga la imagen
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF534AB7),
                      strokeWidth: 2,
                    ),
                  );
                },
                // Error si la imagen no carga
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF3d3a6b),
                    ),
                  );
                },
              )
            // Si no hay imagen, mostramos un icono
            : const Center(
                child: Icon(
                  Icons.checkroom_outlined,
                  color: Color(0xFF3d3a6b),
                  size: 32,
                ),
              ),
      ),
    );
  }
}