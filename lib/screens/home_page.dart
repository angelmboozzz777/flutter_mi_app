import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../widgets/home_widgets.dart';
import 'agregar_producto_page.dart';
import 'producto_detail_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String role;
  final int userId;
  final Usuario usuario;
  final Map<String, dynamic> user;

  const HomePage({
    super.key,
    required this.role,
    required this.userId,
    required this.usuario,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductoService productoService =
      ProductoService();

  List<Producto> productos = [];
  List<String> categorias = [];

  String categoriaSeleccionada = 'Todos';

  bool cargandoProductos = true;
  bool cargandoCategorias = true;

  String? errorProductos;

  @override
  void initState() {
    super.initState();

    cargarProductos();
    cargarCategorias();
  }

  // ==========================================================
  // PRODUCTOS
  // ==========================================================

  Future<void> cargarProductos() async {
    setState(() {
      cargandoProductos = true;
      errorProductos = null;
    });

    try {
      final resultado =
          await productoService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = resultado;
        cargandoProductos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoProductos = false;
        errorProductos =
            'No pudimos cargar los productos.\n'
            'Verifica tu conexión.';
      });
    }
  }

  // ==========================================================
  // CATEGORÍAS
  // ==========================================================

  Future<void> cargarCategorias() async {
    try {
      final resultado =
          await productoService.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        categorias = resultado;
        cargandoCategorias = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoCategorias = false;
      });
    }
  }

  // ==========================================================
  // FILTRAR POR CATEGORÍA
  // ==========================================================

  Future<void> filtrarPorCategoria(
    String categoria,
  ) async {
    setState(() {
      categoriaSeleccionada = categoria;
      productos = [];
      cargandoProductos = true;
      errorProductos = null;
    });

    try {
      final resultado = categoria == 'Todos'
          ? await productoService.obtenerProductos()
          : await productoService
              .obtenerProductosPorCategoria(
              categoria,
            );

      if (!mounted) return;

      setState(() {
        productos = resultado;
        cargandoProductos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoProductos = false;
        errorProductos =
            'No pudimos cargar los productos de esta categoría.';
      });
    }
  }

  // ==========================================================
  // DETALLE DEL PRODUCTO
  // ==========================================================

  Future<void> abrirDetalle(
    Producto producto,
  ) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetailPage(
          productoId: producto.id,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado == 'eliminado') {
      setState(() {
        productos.removeWhere(
          (item) => item.id == producto.id,
        );
      });
    }
  }

  // ==========================================================
  // AGREGAR PRODUCTO
  // ==========================================================

  Future<void> abrirAgregarProducto() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarProductoPage(
          role: widget.role,
        ),
      ),
    );
  }

  // ==========================================================
  // PERFIL
  // ==========================================================

  void abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          role: widget.role,
          userId: widget.userId,
          usuario: widget.usuario,
          user: widget.user,
        ),
      ),
    );
  }

  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return HomeWidgets(
      nombreUsuario: widget.usuario.nombreCompleto,
      categoriaSeleccionada: categoriaSeleccionada,
      categorias: categorias,
      productos: productos,
      cargandoProductos: cargandoProductos,
      cargandoCategorias: cargandoCategorias,
      errorProductos: errorProductos,
      esAdministrador: widget.role == 'Administrador',
      onPerfil: abrirPerfil,
      onAgregarProducto: abrirAgregarProducto,
      onRecargar: cargarProductos,
      onCategoria: filtrarPorCategoria,
      onProducto: abrirDetalle,
    );
  }
}