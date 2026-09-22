import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import '../storage/secure_storage.dart';

class ProductoDetailPage extends StatefulWidget {
  final int productoId;

  const ProductoDetailPage({
    super.key,
    required this.productoId,
  });

  @override
  State<ProductoDetailPage> createState() =>
      _ProductoDetailPageState();
}

class _ProductoDetailPageState
    extends State<ProductoDetailPage> {
  final ProductoService productoService =
      ProductoService();

  final SecureStorageService storageService =
      SecureStorageService();

  Producto? producto;

  bool cargando = true;
  bool procesando = false;

  String? error;
  String rol = '';

  @override
  void initState() {
    super.initState();

    cargarProducto();
  }

  Future<void> cargarProducto() async {
    try {
      final String? rolGuardado =
          await storageService.getRole();

      final Producto resultado =
          await productoService.obtenerProductoPorId(
        widget.productoId,
      );

      if (!mounted) return;

      setState(() {
        rol = rolGuardado ?? '';
        producto = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = 'Producto no disponible';
      });

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  Future<void> editarProducto() async {
    if (producto == null) return;

    final Producto? productoEditado =
        await showDialog<Producto>(
      context: context,
      builder: (context) {
        return _DialogoEditarProducto(
          producto: producto!,
        );
      },
    );

    if (productoEditado == null) {
      return;
    }

    setState(() {
      procesando = true;
    });

    try {
      final Producto resultado =
          await productoService.actualizarProducto(
        productoEditado,
      );

      if (!mounted) return;

      setState(() {
        producto = resultado;
        procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Producto actualizado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar el producto',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> eliminarProducto() async {
    if (producto == null) return;

    final bool? confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar producto',
          ),
          content: Text(
            '¿Seguro que deseas eliminar "${producto!.title}"?',
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    setState(() {
      procesando = true;
    });

    try {
      await productoService.eliminarProducto(
        producto!.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Producto eliminado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        'eliminado',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo eliminar el producto',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Producto',
          ),
        ),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (producto == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Producto no disponible',
          ),
        ),
      );
    }

    final Producto productoActual =
        producto!;

    final bool esAdministrador =
        rol == 'Administrador';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          'Detalle del producto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _imagenProducto(
                  productoActual,
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple
                        .withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    productoActual.category,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  productoActual.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '\$${productoActual.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  productoActual.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                if (esAdministrador) ...[
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: procesando
                              ? null
                              : editarProducto,

                          icon: const Icon(
                            Icons.edit_outlined,
                          ),

                          label: const Text(
                            'Editar',
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.deepPurple,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 15,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: procesando
                              ? null
                              : eliminarProducto,

                          icon: const Icon(
                            Icons.delete_outline,
                          ),

                          label: const Text(
                            'Eliminar',
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 15,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),

          if (procesando)
            Container(
              color: Colors.black.withValues(
                alpha: 0.15,
              ),

              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagenProducto(
    Producto producto,
  ) {
    return Container(
      width: double.infinity,
      height: 310,

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Image.network(
        producto.image,
        fit: BoxFit.contain,

        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey[400],
          );
        },
      ),
    );
  }
}

class _DialogoEditarProducto
    extends StatefulWidget {
  final Producto producto;

  const _DialogoEditarProducto({
    required this.producto,
  });

  @override
  State<_DialogoEditarProducto> createState() =>
      _DialogoEditarProductoState();
}

class _DialogoEditarProductoState
    extends State<_DialogoEditarProducto> {
  late final TextEditingController tituloController;
  late final TextEditingController precioController;
  late final TextEditingController descripcionController;
  late final TextEditingController categoriaController;
  late final TextEditingController imagenController;

  @override
  void initState() {
    super.initState();

    tituloController =
        TextEditingController(
      text: widget.producto.title,
    );

    precioController =
        TextEditingController(
      text: widget.producto.price.toString(),
    );

    descripcionController =
        TextEditingController(
      text: widget.producto.description,
    );

    categoriaController =
        TextEditingController(
      text: widget.producto.category,
    );

    imagenController =
        TextEditingController(
      text: widget.producto.image,
    );
  }

  @override
  void dispose() {
    tituloController.dispose();
    precioController.dispose();
    descripcionController.dispose();
    categoriaController.dispose();
    imagenController.dispose();

    super.dispose();
  }

  void guardar() {
    final String titulo =
        tituloController.text.trim();

    final double? precio =
        double.tryParse(
      precioController.text.trim(),
    );

    final String descripcion =
        descripcionController.text.trim();

    final String categoria =
        categoriaController.text.trim();

    final String imagen =
        imagenController.text.trim();

    if (titulo.isEmpty ||
        precio == null ||
        precio < 0 ||
        descripcion.isEmpty ||
        categoria.isEmpty ||
        imagen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verifica los datos del producto',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final Producto productoActualizado =
        Producto(
      id: widget.producto.id,
      title: titulo,
      price: precio,
      description: descripcion,
      category: categoria,
      image: imagen,
    );

    Navigator.pop(
      context,
      productoActualizado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Editar producto',
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: tituloController,
              decoration:
                  const InputDecoration(
                labelText: 'Título',
                prefixIcon:
                    Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: precioController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Precio',
                prefixIcon:
                    Icon(Icons.attach_money),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  descripcionController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText: 'Descripción',
                prefixIcon:
                    Icon(Icons.description_outlined),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  categoriaController,
              decoration:
                  const InputDecoration(
                labelText: 'Categoría',
                prefixIcon:
                    Icon(Icons.category_outlined),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: imagenController,
              decoration:
                  const InputDecoration(
                labelText: 'URL de imagen',
                prefixIcon:
                    Icon(Icons.image_outlined),
              ),
            ),
          ],
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

        ElevatedButton(
          onPressed: guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.deepPurple,
            foregroundColor:
                Colors.white,
          ),
          child: const Text(
            'Guardar',
          ),
        ),
      ],
    );
  }
}