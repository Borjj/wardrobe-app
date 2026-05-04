import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/garment_service.dart';

class AddGarmentScreen extends StatefulWidget {
  const AddGarmentScreen({super.key});

  @override
  State<AddGarmentScreen> createState() => _AddGarmentScreenState();
}

class _AddGarmentScreenState extends State<AddGarmentScreen> {
  final _garmentService = GarmentService();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  String? _selectedCategory;
  String? _selectedColor;
  String? _selectedSeason;

  final List<String> _categories = [
    'Tops', 'Pantalones', 'Vestidos', 'Faldas',
    'Chaquetas', 'Abrigos', 'Zapatos', 'Accesorios'
  ];

  final List<String> _seasons = [
    'Primavera', 'Verano', 'Otoño', 'Invierno', 'Todo el año'
  ];

  // Colores básicos con su representación visual
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Negro', 'color': Colors.black},
    {'name': 'Blanco', 'color': Colors.white},
    {'name': 'Gris', 'color': Colors.grey},
    {'name': 'Azul', 'color': Colors.blue},
    {'name': 'Rojo', 'color': Colors.red},
    {'name': 'Verde', 'color': Colors.green},
    {'name': 'Amarillo', 'color': Colors.yellow},
    {'name': 'Rosa', 'color': Colors.pink},
    {'name': 'Naranja', 'color': Colors.orange},
    {'name': 'Marrón', 'color': Colors.brown},
    {'name': 'Beige', 'color': const Color(0xFFF5F5DC)},
    {'name': 'Morado', 'color': Colors.purple},
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  // Abre la cámara o galería para seleccionar imagen
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // Muestra el bottomsheet para elegir cámara o galería
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242235),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF534AB7)),
              title: const Text('Hacer foto',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF534AB7)),
              title: const Text('Elegir de la galería',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGarment() async {
    // Validaciones mínimas
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade una foto de la prenda')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un color')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: subir imagen a Cloudinary y obtener URL
      // TODO: llamar a Remove.bg para eliminar fondo
      // Por ahora guardamos con URL vacía para testear el flujo
      await _garmentService.createGarment(
        imageUrl: 'placeholder',
        category: _selectedCategory!,
        color: _selectedColor!,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        size: _sizeController.text.trim().isEmpty
            ? null
            : _sizeController.text.trim(),
        season: _selectedSeason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prenda añadida al armario')),
        );
        Navigator.pop(context); // Volvemos al armario
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando la prenda: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1825),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242235),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Añadir prenda',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Botón guardar en la barra superior
          TextButton(
            onPressed: _isLoading ? null : _saveGarment,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF534AB7),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Color(0xFF534AB7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de imagen
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF242235),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3d3a6b)),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 48,
                            color: Color(0xFF534AB7),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Añade una foto',
                            style: TextStyle(
                              color: Color(0xFF9996cc),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Cámara o galería',
                            style: TextStyle(
                              color: Color(0xFF6e6b99),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Selector de categoría
            _buildSectionLabel('Categoría *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
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
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9996cc),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Selector de color
            _buildSectionLabel('Color *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((c) {
                final isSelected = _selectedColor == c['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c['name']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Punto de color como referencia visual
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: c['color'],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6e6b99),
                              width: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          c['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF9996cc),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Selector de temporada
            _buildSectionLabel('Temporada'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _seasons.map((s) {
                final isSelected = _selectedSeason == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSeason = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
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
                    child: Text(
                      s,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9996cc),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Campo marca
            _buildSectionLabel('Marca'),
            const SizedBox(height: 8),
            TextField(
              controller: _brandController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Zara, H&M, Nike...',
                hintStyle: TextStyle(color: Color(0xFF6e6b99)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3d3a6b)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF534AB7)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo talla
            _buildSectionLabel('Talla'),
            const SizedBox(height: 8),
            TextField(
              controller: _sizeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'S, M, L, 38, 40...',
                hintStyle: TextStyle(color: Color(0xFF6e6b99)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3d3a6b)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF534AB7)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper para los títulos de sección
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF9996cc),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}