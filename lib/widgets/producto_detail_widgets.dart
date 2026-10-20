import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../theme/game_theme.dart';
import 'carrito_widgets.dart';

class ProductoDetailWidgets extends StatelessWidget {
  final Producto producto;
  final bool esAdministrador;
  final bool procesando;

  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  // US09 - carrito
  final bool puedeComprar;
  final int cantidad;
  final bool agregando;
  final void Function(int) onCambiarCantidad;
  final VoidCallback onAgregarCarrito;

  // Piezas que todavía se pueden agregar (stock - lo que ya hay
  // en el carrito).
  final int maxCantidad;

  const ProductoDetailWidgets({
    super.key,
    required this.producto,
    required this.esAdministrador,
    required this.procesando,
    required this.onEditar,
    required this.onEliminar,
    required this.puedeComprar,
    required this.cantidad,
    required this.agregando,
    required this.onCambiarCantidad,
    required this.onAgregarCarrito,
    required this.maxCantidad,
  });

  bool get agotado => producto.stock <= 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del juego'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portada (proporción de las portadas de Steam).
                    AspectRatio(
                      aspectRatio: 460 / 215,
                      child: PortadaJuego(
                        url: producto.image,
                        iconoSize: 64,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.title,
                            style: const TextStyle(
                              color: GameColors.texto,
                              fontSize: 24,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Etiqueta(
                                texto: producto.category,
                                icono: Icons.category_outlined,
                              ),
                              Etiqueta(
                                texto: producto.platform,
                                icono: Icons.devices_other_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _panelCompra(),

                          const SizedBox(height: 24),

                          const TituloSeccion('Descripción'),

                          const SizedBox(height: 8),

                          Text(
                            producto.description,
                            style: const TextStyle(
                              color: GameColors.textoSecundario,
                              fontSize: 15,
                              height: 1.55,
                            ),
                          ),

                          if (esAdministrador) ...[
                            const SizedBox(height: 28),
                            const TituloSeccion('Administración'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        procesando ? null : onEditar,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Editar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        procesando ? null : onEliminar,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                    ),
                                    label: const Text('Eliminar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: GameColors.peligro,
                                      side: BorderSide(
                                        color: GameColors.peligro
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (procesando)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Precio, disponibilidad y (si puede comprar) el botón del carrito.
  Widget _panelCompra() {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatoPrecio(producto.price),
            style: const TextStyle(
              color: GameColors.texto,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          _disponibilidad(),

          // El Auditor no ve esta parte.
          if (puedeComprar) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SelectorCantidad(
                  cantidad: cantidad,
                  onMenos: cantidad > 1 && !agregando
                      ? () => onCambiarCantidad(cantidad - 1)
                      : null,
                  onMas: !agregando && cantidad < maxCantidad
                      ? () => onCambiarCantidad(cantidad + 1)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BotonPrincipal(
                    texto: agotado
                        ? 'Agotado'
                        : maxCantidad <= 0
                            ? 'Ya tienes todo el stock'
                            : 'Agregar al carrito',
                    icono: Icons.add_shopping_cart_rounded,
                    cargando: agregando,
                    onPressed: maxCantidad <= 0 ? null : onAgregarCarrito,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _disponibilidad() {
    final Color color = agotado ? GameColors.peligro : GameColors.exito;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            agotado ? 'Agotado' : 'En stock (${producto.stock})',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// DIÁLOGO PARA EDITAR PRODUCTO
// ==========================================================

class DialogoEditarProducto extends StatefulWidget {
  final Producto producto;

  const DialogoEditarProducto({
    super.key,
    required this.producto,
  });

  @override
  State<DialogoEditarProducto> createState() =>
      _DialogoEditarProductoState();
}

class _DialogoEditarProductoState
    extends State<DialogoEditarProducto> {
  late final TextEditingController tituloController;
  late final TextEditingController precioController;
  late final TextEditingController descripcionController;
  late final TextEditingController categoriaController;
  late final TextEditingController plataformaController;
  late final TextEditingController stockController;
  late final TextEditingController imagenController;

  // Mensaje de validación que se muestra dentro del diálogo.
  String? error;

  @override
  void initState() {
    super.initState();

    tituloController = TextEditingController(
      text: widget.producto.title,
    );

    precioController = TextEditingController(
      text: widget.producto.price.toStringAsFixed(2),
    );

    descripcionController = TextEditingController(
      text: widget.producto.description,
    );

    categoriaController = TextEditingController(
      text: widget.producto.category,
    );

    plataformaController = TextEditingController(
      text: widget.producto.platform,
    );

    stockController = TextEditingController(
      text: widget.producto.stock.toString(),
    );

    imagenController = TextEditingController(
      text: widget.producto.image,
    );
  }

  @override
  void dispose() {
    tituloController.dispose();
    precioController.dispose();
    descripcionController.dispose();
    categoriaController.dispose();
    plataformaController.dispose();
    stockController.dispose();
    imagenController.dispose();

    super.dispose();
  }

  // Devuelve el primer problema encontrado, o null si todo está bien.
  String? validar({
    required String titulo,
    required double? precio,
    required String descripcion,
    required String categoria,
    required int? stock,
    required String imagen,
  }) {
    if (titulo.isEmpty) return 'El título es obligatorio';

    // La API exige un precio mayor que 0.
    if (precio == null) return 'El precio debe ser numérico';
    if (precio <= 0) return 'El precio debe ser mayor que 0';

    if (descripcion.isEmpty) return 'La descripción es obligatoria';
    if (categoria.isEmpty) return 'La categoría es obligatoria';

    if (stock == null || stock < 0) {
      return 'El stock debe ser un número entero (0 o más)';
    }

    final Uri? uri = Uri.tryParse(imagen);
    final bool urlValida = uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (!urlValida) return 'Ingresa una URL de imagen válida';

    return null;
  }

  void guardar() {
    final String titulo = tituloController.text.trim();
    final double? precio = double.tryParse(precioController.text.trim());
    final String descripcion = descripcionController.text.trim();
    final String categoria = categoriaController.text.trim();
    final String plataforma = plataformaController.text.trim();
    final int? stock = int.tryParse(stockController.text.trim());
    final String imagen = imagenController.text.trim();

    final String? problema = validar(
      titulo: titulo,
      precio: precio,
      descripcion: descripcion,
      categoria: categoria,
      stock: stock,
      imagen: imagen,
    );

    if (problema != null) {
      setState(() {
        error = problema;
      });
      return;
    }

    final Producto productoActualizado = Producto(
      id: widget.producto.id,
      title: titulo,
      price: precio!,
      description: descripcion,
      category: categoria,
      image: imagen,
      platform: plataforma,
      stock: stock!,
    );

    Navigator.pop(
      context,
      productoActualizado,
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: GameColors.texto),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Editar juego',
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              _campo(tituloController, 'Título'),
              Row(
                children: [
                  Expanded(
                    child: _campo(
                      precioController,
                      'Precio',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _campo(
                      stockController,
                      'Stock',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _campo(categoriaController, 'Categoría'),
              _campo(plataformaController, 'Plataforma'),
              _campo(
                descripcionController,
                'Descripción',
                maxLines: 3,
              ),
              _campo(imagenController, 'URL de la portada'),
              if (error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GameColors.peligro.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: GameColors.peligro,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancelar',
          ),
        ),
        FilledButton(
          onPressed: guardar,
          child: const Text(
            'Guardar cambios',
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// DIÁLOGO PARA CONFIRMAR ELIMINACIÓN
// ==========================================================

Future<bool?> mostrarDialogoEliminar(
  BuildContext context,
  String tituloProducto,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Eliminar juego',
        ),
        content: Text(
          '¿Seguro que deseas eliminar "$tituloProducto"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Cancelar',
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: GameColors.peligro,
            ),
            child: const Text(
              'Eliminar',
            ),
          ),
        ],
      );
    },
  );
}
