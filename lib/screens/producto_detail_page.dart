import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import '../storage/secure_storage.dart';
import '../widgets/producto_detail_widgets.dart';

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

  // ==========================================================
  // CARGAR PRODUCTO
  // ==========================================================

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

  // ==========================================================
  // EDITAR PRODUCTO
  // ==========================================================

  Future<void> editarProducto() async {
    // Solo el administrador puede editar.
    if (rol != 'Administrador') {
      return;
    }

    if (producto == null) return;

    final Producto? productoEditado =
        await showDialog<Producto>(
      context: context,
      builder: (context) {
        return DialogoEditarProducto(
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
            'Producto actualizado (Simulación)',
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

  // ==========================================================
  // ELIMINAR PRODUCTO
  // ==========================================================

  Future<void> eliminarProducto() async {
    // Solo el administrador puede eliminar.
    if (rol != 'Administrador') {
      return;
    }

    if (producto == null) return;

    final bool? confirmar =
        await mostrarDialogoEliminar(
      context,
      producto!.title,
    );

    // Cancelar no realiza ninguna petición.
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

  // ==========================================================
  // INTERFAZ
  // ==========================================================

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

    final bool esAdministrador =
        rol == 'Administrador';

    return ProductoDetailWidgets(
      producto: producto!,
      esAdministrador: esAdministrador,
      procesando: procesando,
      onEditar: editarProducto,
      onEliminar: eliminarProducto,
    );
  }
}