import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
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
  final ProductoService productoService = ProductoService();

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

  // Abre el detalle y actualiza el catálogo si se elimina un producto.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Mi tienda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Descubre nuestros productos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: abrirPerfil,
            tooltip: 'Mi perfil',

            icon: Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.person_outline,
                color: Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: cargarProductos,

        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          slivers: [
            SliverToBoxAdapter(
              child: _encabezadoTienda(),
            ),

            SliverToBoxAdapter(
              child: _seccionCategorias(),
            ),

            SliverToBoxAdapter(
              child: _tituloProductos(),
            ),

            if (cargandoProductos)
              const SliverFillRemaining(
                hasScrollBody: false,

                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                ),
              )
            else if (errorProductos != null)
              SliverFillRemaining(
                hasScrollBody: false,

                child: _errorProductos(),
              )
            else if (productos.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,

                child: Center(
                  child: Text(
                    'No hay productos disponibles.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  30,
                ),

                sliver: SliverGrid(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final producto =
                          productos[index];

                      return _tarjetaProducto(
                        producto,
                      );
                    },

                    childCount:
                        productos.length,
                  ),

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.67,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _encabezadoTienda() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        10,
      ),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C3FCB),
            Color(0xFF8E62E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(
              alpha: 0.22,
            ),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  '¡Hola! 👋',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.usuario.nombreCompleto,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Encuentra algo que te guste.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionCategorias() {
    if (cargandoCategorias) {
      return const SizedBox(
        height: 55,

        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    return SizedBox(
      height: 55,

      child: ListView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        scrollDirection: Axis.horizontal,

        children: [
          _chipCategoria('Todos'),

          ...categorias.map(
            (categoria) =>
                _chipCategoria(categoria),
          ),
        ],
      ),
    );
  }

  Widget _chipCategoria(
    String categoria,
  ) {
    final bool seleccionada =
        categoriaSeleccionada == categoria;

    return Padding(
      padding:
          const EdgeInsets.only(right: 9),

      child: ChoiceChip(
        label: Text(
          categoria == 'Todos'
              ? 'Todos'
              : _formatearCategoria(
                  categoria,
                ),
        ),

        selected: seleccionada,

        onSelected: (_) {
          filtrarPorCategoria(
            categoria,
          );
        },

        selectedColor:
            Colors.deepPurple,

        backgroundColor:
            Colors.white,

        labelStyle: TextStyle(
          color: seleccionada
              ? Colors.white
              : Colors.black87,

          fontWeight:
              FontWeight.w600,
        ),

        side: BorderSide(
          color: seleccionada
              ? Colors.deepPurple
              : Colors.grey.shade300,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),
      ),
    );
  }

  String _formatearCategoria(
    String categoria,
  ) {
    return categoria
        .split(' ')
        .map(
          (palabra) => palabra.isEmpty
              ? palabra
              : palabra[0].toUpperCase() +
                  palabra.substring(1),
        )
        .join(' ');
  }

  Widget _tituloProductos() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        14,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          const Text(
            'Productos',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (!cargandoProductos &&
              errorProductos == null)
            Text(
              '${productos.length} productos',

              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaProducto(
    Producto producto,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),

      onTap: () {
        abrirDetalle(producto);
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.06,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Expanded(
              flex: 5,

              child: Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.grey[50],

                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
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
                      Icons
                          .image_not_supported_outlined,
                      size: 45,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),

            Expanded(
              flex: 4,

              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  13,
                  11,
                  13,
                  10,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      producto.category,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.deepPurple[400],
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      producto.title,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        Text(
                          '\$${producto.price.toStringAsFixed(2)}',

                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.deepPurple,
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.all(
                            6,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .deepPurple
                                .withValues(
                              alpha: 0.1,
                            ),
                            shape:
                                BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 12,
                            color:
                                Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorProductos() {
    return Padding(
      padding: const EdgeInsets.all(30),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Container(
            padding:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.cloud_off_outlined,
              size: 45,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            errorProductos!,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: cargarProductos,

            icon: const Icon(
              Icons.refresh,
            ),

            label: const Text(
              'Reintentar',
            ),

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.deepPurple,
              foregroundColor:
                  Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}