import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/producto.dart';
import '../services/carrito_service.dart';
import '../services/consulta_service.dart';
import '../services/producto_service.dart';
import '../widgets/home_widgets.dart';
import 'agregar_producto_page.dart';
import 'carrito_page.dart';
import 'carritos_globales_page.dart';
import 'producto_detail_page.dart';
import 'profile_page.dart';
import 'usuarios_page.dart';

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
  final ProductoService productoService = ProductoService();

  List<Producto> productos = [];
  List<String> categorias = [];

  String categoriaSeleccionada = 'Todos';

  // Texto escrito en el buscador.
  String busqueda = '';

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
      final resultado = await productoService.obtenerProductos();

      // Si mientras tanto se eligió una categoría, esta lista ya no aplica.
      if (!mounted || categoriaSeleccionada != 'Todos') return;

      setState(() {
        productos = resultado;
        cargandoProductos = false;
      });
    } catch (e) {
      if (!mounted || categoriaSeleccionada != 'Todos') return;

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
      final resultado = await productoService.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        categorias = resultado;
        cargandoCategorias = false;
      });

      // La categoría elegida ya no existe (se borró su último juego).
      if (categoriaSeleccionada != 'Todos' &&
          !resultado.contains(categoriaSeleccionada)) {
        filtrarPorCategoria('Todos');
      }
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

  Future<void> filtrarPorCategoria(String categoria) async {
    setState(() {
      categoriaSeleccionada = categoria;
      productos = [];
      cargandoProductos = true;
      errorProductos = null;
    });

    try {
      final resultado = categoria == 'Todos'
          ? await productoService.obtenerProductos()
          : await productoService.obtenerProductosPorCategoria(categoria);

      if (!mounted) return;

      // Mientras esperaba se eligió otra categoría: esta respuesta ya
      // no sirve (pasa si se tocan los filtros muy rápido).
      if (categoria != categoriaSeleccionada) return;

      setState(() {
        productos = resultado;
        cargandoProductos = false;
      });
    } catch (e) {
      if (!mounted || categoria != categoriaSeleccionada) return;

      setState(() {
        cargandoProductos = false;
        errorProductos = 'No pudimos cargar los productos de esta categoría.';
      });
    }
  }

  // ==========================================================
  // RECARGAR (deslizar hacia abajo o "Reintentar")
  // ==========================================================

  // Respeta la categoría elegida y actualiza los filtros.
  Future<void> recargar() async {
    await Future.wait([
      cargarCategorias(),
      filtrarPorCategoria(categoriaSeleccionada),
    ]);
  }

  // ==========================================================
  // BÚSQUEDA
  // ==========================================================

  void buscar(String texto) {
    setState(() {
      busqueda = texto.trim();
    });
  }

  // Filtra la lista cargada por título, categoría o plataforma.
  List<Producto> get productosVisibles {
    if (busqueda.isEmpty) return productos;

    final String texto = busqueda.toLowerCase();

    return productos
        .where(
          (producto) =>
              producto.title.toLowerCase().contains(texto) ||
              producto.category.toLowerCase().contains(texto) ||
              producto.platform.toLowerCase().contains(texto),
        )
        .toList();
  }

  // ==========================================================
  // DETALLE DEL PRODUCTO
  // ==========================================================

  Future<void> abrirDetalle(Producto producto) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetailPage(productoId: producto.id),
      ),
    );

    if (!mounted) return;

    if (resultado == 'eliminado') {
      setState(() {
        productos.removeWhere((item) => item.id == producto.id);
      });

      // Si era el último de su categoría, el filtro desaparece.
      cargarCategorias();
    } else if (resultado is Producto) {
      // Se editó: la tarjeta muestra los datos nuevos.
      final int indice = productos.indexWhere(
        (item) => item.id == resultado.id,
      );

      setState(() {
        if (indice >= 0) productos[indice] = resultado;
      });

      // La categoría pudo cambiar.
      cargarCategorias();

      if (categoriaSeleccionada != 'Todos' &&
          resultado.category != categoriaSeleccionada) {
        filtrarPorCategoria(categoriaSeleccionada);
      }
    }
  }

  // ==========================================================
  // AGREGAR PRODUCTO
  // ==========================================================

  Future<void> abrirAgregarProducto() async {
    final creados = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarProductoPage(role: widget.role),
      ),
    );

    if (!mounted) return;

    // Si se agregó algún producto, recargamos la lista y las categorías.
    if (creados != null && creados > 0) {
      cargarCategorias();
      filtrarPorCategoria(categoriaSeleccionada);
    }
  }

  // ==========================================================
  // CARRITO (US09 / US10)
  // ==========================================================

  // El Auditor solo consulta; Cliente y Administrador pueden comprar.
  bool get puedeComprar =>
      widget.role == 'Cliente' || widget.role == 'Administrador';

  void abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarritoPage()),
    );
  }

  // Desde el catálogo se agrega 1 pieza. Si el juego ya está
  // en el carrito, se suma a la cantidad que ya había.
  Future<void> agregarRapido(Producto producto) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await CarritoService.instancia.agregar(producto, 1);

      final int enCarrito = CarritoService.instancia.cantidadDe(producto.id);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '"${producto.title}" añadido al carrito '
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
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  // ==========================================================
  // PERFIL
  // ==========================================================

  // ==========================================================
  // PANEL DE CONSULTA (US11 / US12) - Administrador y Auditor
  // ==========================================================

  bool get puedeConsultar => Permisos.puedeConsultarTodo(widget.role);

  void abrirUsuarios() {
    if (!puedeConsultar) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuariosPage(role: widget.role),
      ),
    );
  }

  void abrirCarritosGlobales() {
    if (!puedeConsultar) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarritosGlobalesPage(role: widget.role),
      ),
    );
  }

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
      productos: productosVisibles,
      cargandoProductos: cargandoProductos,
      cargandoCategorias: cargandoCategorias,
      errorProductos: errorProductos,
      esAdministrador: widget.role == 'Administrador',
      onPerfil: abrirPerfil,
      onAgregarProducto: abrirAgregarProducto,
      onRecargar: recargar,
      onCategoria: filtrarPorCategoria,
      onProducto: abrirDetalle,
      puedeComprar: puedeComprar,
      onCarrito: abrirCarrito,
      onAgregarRapido: agregarRapido,
      busqueda: busqueda,
      onBuscar: buscar,
      puedeConsultar: puedeConsultar,
      onUsuarios: abrirUsuarios,
      onCarritosGlobales: abrirCarritosGlobales,
    );
  }
}
