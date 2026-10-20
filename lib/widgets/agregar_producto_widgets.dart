import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class AgregarProductoWidgets extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController precioController;
  final TextEditingController descripcionController;
  final TextEditingController imagenController;
  final TextEditingController categoriaController;
  final TextEditingController plataformaController;
  final TextEditingController stockController;

  final bool guardando;

  final String? errorTitulo;
  final String? errorPrecio;
  final String? errorDescripcion;
  final String? errorImagen;
  final String? errorCategoria;
  final String? errorStock;

  final VoidCallback onGuardar;

  const AgregarProductoWidgets({
    super.key,
    required this.tituloController,
    required this.precioController,
    required this.descripcionController,
    required this.imagenController,
    required this.categoriaController,
    required this.plataformaController,
    required this.stockController,
    required this.guardando,
    required this.errorTitulo,
    required this.errorPrecio,
    required this.errorDescripcion,
    required this.errorImagen,
    required this.errorCategoria,
    required this.errorStock,
    required this.onGuardar,
  });

  // Plataformas sugeridas para llenar el campo con un toque.
  static const List<String> plataformas = [
    'PC',
    'PS5',
    'Xbox Series X',
    'Nintendo Switch',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar juego'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Completa la ficha del juego para publicarlo '
                  'en el catálogo.',
                  style: TextStyle(
                    color: GameColors.textoSecundario,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                _seccion(
                  'Información básica',
                  [
                    _campo(
                      controller: tituloController,
                      label: 'Título',
                      hint: 'Ej. Hollow Knight',
                      error: errorTitulo,
                    ),
                    _campo(
                      controller: categoriaController,
                      label: 'Categoría',
                      hint: 'Ej. RPG, Shooter, Indie',
                      error: errorCategoria,
                    ),
                    _campo(
                      controller: plataformaController,
                      label: 'Plataforma',
                      hint: 'Ej. PC',
                      error: null,
                    ),
                    _selectorPlataforma(),
                    _campo(
                      controller: descripcionController,
                      label: 'Descripción',
                      hint: '¿De qué trata el juego?',
                      error: errorDescripcion,
                      maxLines: 4,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _seccion(
                  'Precio e inventario',
                  [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _campo(
                            controller: precioController,
                            label: 'Precio (MXN)',
                            hint: 'Ej. 249.99',
                            error: errorPrecio,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: stockController,
                            label: 'Stock',
                            hint: 'Ej. 30',
                            error: errorStock,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _seccion(
                  'Portada',
                  [
                    _campo(
                      controller: imagenController,
                      label: 'URL de la imagen',
                      hint: 'https://...',
                      error: errorImagen,
                      keyboardType: TextInputType.url,
                    ),
                    _vistaPrevia(),
                  ],
                ),

                const SizedBox(height: 20),

                BotonPrincipal(
                  texto: 'Guardar juego',
                  cargando: guardando,
                  onPressed: onGuardar,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo, List<Widget> campos) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: GameColors.texto,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final campo in campos) ...[
            const SizedBox(height: 14),
            campo,
          ],
        ],
      ),
    );
  }

  // Se actualiza mientras se escribe en el campo de plataforma.
  Widget _selectorPlataforma() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: plataformaController,
      builder: (context, valor, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: plataformas.map((plataforma) {
            final bool elegida = valor.text.trim() == plataforma;

            return ChoiceChip(
              label: Text(plataforma),
              selected: elegida,
              onSelected: guardando
                  ? null
                  : (_) {
                      plataformaController.text = plataforma;
                    },
              side: BorderSide(
                color: elegida ? GameColors.acento : GameColors.borde,
              ),
              labelStyle: TextStyle(
                color: elegida ? Colors.white : GameColors.textoSecundario,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Muestra la portada en cuanto la URL parece válida.
  Widget _vistaPrevia() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: imagenController,
      builder: (context, valor, _) {
        final String url = valor.text.trim();
        final Uri? uri = Uri.tryParse(url);
        final bool pareceUrl = uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.hasAuthority;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 460 / 215,
            child: pareceUrl
                ? PortadaJuego(url: url, iconoSize: 40)
                : Container(
                    color: GameColors.superficieAlta,
                    alignment: Alignment.center,
                    child: const Text(
                      'Vista previa de la portada',
                      style: TextStyle(
                        color: GameColors.textoTenue,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? error,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !guardando,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: GameColors.texto),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        errorMaxLines: 2,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
