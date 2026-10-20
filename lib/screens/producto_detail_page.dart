import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/carrito_service.dart';
import '../services/producto_service.dart';
import '../storage/secure_storage.dart';
import '../widgets/producto_detail_widgets.dart';
import 'carrito_page.dart';

class ProductoDetailPage extends StatefulWidget {
  final int productoId;

  const ProductoDetailPage({super.key, required this.productoId});

  @override
  State<ProductoDetailPage> createState() => _ProductoDetailPageState();
}

class _ProductoDetailPageState extends State<ProductoDetailPage> {
  final ProductoService productoService = ProductoService();

  final SecureStorageService storageService = SecureStorageService();

  Producto? producto;

  bool cargando = true;
  bool procesando = false;

  // US09 - cantidad elegida y estado del botón del carrito.
  int cantidad = 1;
  bool agregando = false;

  String? error;
  String rol = '';

  // true si el administrador editó el juego; al regresar, el
  // catálogo recibe el producto actualizado.
  bool editado = false;

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
      final String? rolGuardado = await storageService.getRole();

      final Producto resultado = await productoService.obtenerProductoPorId(
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

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  // ==========================================================
  // US09 - AGREGAR AL CARRITO
  // ==========================================================

  // El Auditor solo puede consultar (solo lectura).
  bool get puedeComprar => rol == 'Cliente' || rol == 'Administrador';

  // Lo que todavía se puede agregar sin pasar el stock.
  int get maxCantidad =>
      producto == null ? 0 : CarritoService.instancia.disponiblePara(producto!);

  // La cantidad elegida nunca pasa de lo disponible.
  int get cantidadValida {
    final int max = maxCantidad;
    return cantidad > max && max >= 1 ? max : cantidad;
  }

  void cambiarCantidad(int nueva) {
    if (nueva < 1 || nueva > maxCantidad) return;

    setState(() {
      cantidad = nueva;
    });
  }

  Future<void> agregarAlCarrito() async {
    if (!puedeComprar || producto == null) return;

    setState(() {
      agregando = true;
    });

    try {
      await CarritoService.instancia.agregar(producto!, cantidadValida);

      if (!mounted) return;

      final int enCarrito = CarritoService.instancia.cantidadDe(producto!.id);

      setState(() {
        agregando = false;
        cantidad = 1;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '"${producto!.title}" añadido al carrito '
              '($enCarrito en total)',
            ),
            backgroundColor: Colors.green,
            // Con botón, Flutter la deja fija; así se quita sola.
            persist: false,
            action: SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: abrirCarrito,
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        agregando = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarritoPage()),
    );
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

    final Producto? productoEditado = await showDialog<Producto>(
      context: context,
      builder: (context) {
        return DialogoEditarProducto(producto: producto!);
      },
    );

    if (productoEditado == null) {
      return;
    }

    setState(() {
      procesando = true;
    });

    try {
      final Producto resultado = await productoService.actualizarProducto(
        productoEditado,
      );

      if (!mounted) return;

      // El carrito también usa los datos nuevos (precio, título...).
      CarritoService.instancia.actualizarProducto(resultado);

      setState(() {
        producto = resultado;
        procesando = false;
        editado = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
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

    final bool? confirmar = await mostrarDialogoEliminar(
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
      await productoService.eliminarProducto(producto!.id);

      // La API ya lo borró de los carritos; aquí se quita de la memoria.
      CarritoService.instancia.quitarLocal(producto!.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pop(context, 'eliminado');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (producto == null) {
      return const Scaffold(
        body: Center(child: Text('Producto no disponible')),
      );
    }

    final bool esAdministrador = rol == 'Administrador';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Si se editó, el catálogo recibe el producto actualizado.
        Navigator.pop(context, editado ? producto : null);
      },
      // Se redibuja si el carrito cambia (por ejemplo, desde "VER").
      child: ListenableBuilder(
        listenable: CarritoService.instancia,
        builder: (context, _) => ProductoDetailWidgets(
          producto: producto!,
          esAdministrador: esAdministrador,
          procesando: procesando,
          onEditar: editarProducto,
          onEliminar: eliminarProducto,
          puedeComprar: puedeComprar,
          cantidad: cantidadValida,
          agregando: agregando,
          onCambiarCantidad: cambiarCantidad,
          onAgregarCarrito: agregarAlCarrito,
          maxCantidad: maxCantidad,
        ),
      ),
    );
  }
}
