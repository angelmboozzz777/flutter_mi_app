import 'package:flutter/material.dart';

class AgregarProductoWidgets extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController precioController;
  final TextEditingController descripcionController;
  final TextEditingController imagenController;
  final TextEditingController categoriaController;

  final bool guardando;

  final String? errorTitulo;
  final String? errorPrecio;
  final String? errorDescripcion;
  final String? errorImagen;
  final String? errorCategoria;

  final VoidCallback onGuardar;

  const AgregarProductoWidgets({
    super.key,
    required this.tituloController,
    required this.precioController,
    required this.descripcionController,
    required this.imagenController,
    required this.categoriaController,
    required this.guardando,
    required this.errorTitulo,
    required this.errorPrecio,
    required this.errorDescripcion,
    required this.errorImagen,
    required this.errorCategoria,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Agregar producto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo producto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Completa la información del producto.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            _campo(
              controller: tituloController,
              label: 'Título',
              hint: 'Nombre del producto',
              icono: Icons.title,
              error: errorTitulo,
            ),

            const SizedBox(height: 16),

            _campo(
              controller: precioController,
              label: 'Precio',
              hint: 'Ej. 29.99',
              icono: Icons.attach_money,
              error: errorPrecio,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 16),

            _campo(
              controller: descripcionController,
              label: 'Descripción',
              hint: 'Descripción del producto',
              icono: Icons.description_outlined,
              error: errorDescripcion,
              maxLines: 4,
            ),

            const SizedBox(height: 16),

            _campo(
              controller: imagenController,
              label: 'URL de imagen',
              hint: 'https://...',
              icono: Icons.image_outlined,
              error: errorImagen,
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 16),

            _campo(
              controller: categoriaController,
              label: 'Categoría',
              hint: 'Ej. electronics',
              icono: Icons.category_outlined,
              error: errorCategoria,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: guardando ? null : onGuardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: guardando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar producto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icono,
    required String? error,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icono,
          color: Colors.deepPurple,
        ),
        errorText: error,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
      ),
    );
  }
}