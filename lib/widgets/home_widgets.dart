import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/carrito_service.dart';
import '../theme/game_theme.dart';

class HomeWidgets extends StatelessWidget {
  final String nombreUsuario;
  final String categoriaSeleccionada;
  final List<String> categorias;
  final List<Producto> productos;

  final bool cargandoProductos;
  final bool cargandoCategorias;
  final String? errorProductos;

  final VoidCallback onPerfil;
  final VoidCallback onAgregarProducto;
  final Future<void> Function() onRecargar;
  final Function(String) onCategoria;
  final Function(Producto) onProducto;

  final bool esAdministrador;

  // US09 - el Auditor no ve nada del carrito.
  final bool puedeComprar;

  // US11 / US12 - panel de consulta (solo Administrador y Auditor).
  final bool puedeConsultar;
  final VoidCallback onUsuarios;
  final VoidCallback onCarritosGlobales;
  final VoidCallback onCarrito;
  final Function(Producto) onAgregarRapido;

  // Búsqueda por título dentro de la lista cargada.
  final String busqueda;
  final Function(String) onBuscar;

  const HomeWidgets({
    super.key,
    required this.nombreUsuario,
    required this.categoriaSeleccionada,
    required this.categorias,
    required this.productos,
    required this.cargandoProductos,
    required this.cargandoCategorias,
    required this.errorProductos,
    required this.onPerfil,
    required this.onAgregarProducto,
    required this.onRecargar,
    required this.onCategoria,
    required this.onProducto,
    required this.esAdministrador,
    required this.puedeComprar,
    required this.onCarrito,
    required this.onAgregarRapido,
    required this.busqueda,
    required this.onBuscar,
    required this.puedeConsultar,
    required this.onUsuarios,
    required this.onCarritosGlobales,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: GameColors.acento,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            // Con letra grande el nombre se corta en vez de desbordarse.
            const Flexible(
              child: Text(
                'GameStore',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Escenario 2 (US11 y US12): el Cliente nunca ve este botón.
          if (puedeConsultar)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => _abrirPanel(context),
                tooltip: 'Panel de consulta',
                icon: const Icon(Icons.space_dashboard_outlined),
              ),
            ),
          if (puedeComprar) _botonCarrito(),
          IconButton(
            onPressed: onPerfil,
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),

      // El botón para agregar juegos solo lo ve el administrador.
      floatingActionButton: esAdministrador
          ? FloatingActionButton.extended(
              onPressed: onAgregarProducto,
              icon: const Icon(Icons.add),
              label: const Text(
                'Agregar juego',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: onRecargar,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _encabezado()),

            SliverToBoxAdapter(child: _seccionCategorias()),

            SliverToBoxAdapter(child: _tituloProductos()),

            if (cargandoProductos)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorProductos != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _errorProductos(),
              )
            else if (productos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _sinResultados(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _tarjetaProducto(productos[index]);
                      }, childCount: productos.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _columnas(constraints.crossAxisExtent),
                        mainAxisExtent: _altoTarjeta(
                          context,
                          constraints.crossAxisExtent,
                        ),
                        crossAxisSpacing: _espacio,
                        mainAxisSpacing: _espacio,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAMAÑO DE LAS TARJETAS
  // La altura se calcula con el ancho real y con el tamaño de letra
  // del teléfono, para que el texto nunca se salga de la tarjeta.
  // ----------------------------------------------------------

  static const double _espacio = 12;
  static const double _anchoMaximo = 260;

  int _columnas(double ancho) {
    final int columnas = ((ancho + _espacio) / (_anchoMaximo + _espacio))
        .ceil();
    return columnas < 2 ? 2 : columnas;
  }

  double _altoTarjeta(BuildContext context, double ancho) {
    final int columnas = _columnas(ancho);
    final double anchoTarjeta =
        (ancho - _espacio * (columnas - 1)) / columnas;
    final double altoPortada = anchoTarjeta * 215 / 460;
    final double escala = MediaQuery.textScalerOf(context).scale(1);

    // Título (2 renglones) + categoría + precio + márgenes.
    return altoPortada + 20 + 70 * escala + 38;
  }

  // Menú del panel: Usuarios (US11) e Historial de carritos (US12).
  void _abrirPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameColors.superficie,
      showDragHandle: true,
      builder: (contextoMenu) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    'Panel de consulta',
                    style: TextStyle(
                      color: GameColors.texto,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Información de toda la tienda (solo lectura).',
                    style: TextStyle(
                      color: GameColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                ),
                _opcionPanel(
                  icono: Icons.people_outline,
                  titulo: 'Usuarios',
                  subtitulo: 'Directorio de cuentas registradas',
                  onTap: () {
                    Navigator.pop(contextoMenu);
                    onUsuarios();
                  },
                ),
                _opcionPanel(
                  icono: Icons.receipt_long_outlined,
                  titulo: 'Historial de carritos',
                  subtitulo: 'Compras de todos los clientes',
                  onTap: () {
                    Navigator.pop(contextoMenu);
                    onCarritosGlobales();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _opcionPanel({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: GameColors.acento.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: GameColors.acento),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          color: GameColors.texto,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(color: GameColors.textoSecundario, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: GameColors.textoTenue),
    );
  }

  // Icono del carrito con el número de piezas.
  Widget _botonCarrito() {
    return ListenableBuilder(
      listenable: CarritoService.instancia,
      builder: (context, _) {
        final int piezas = CarritoService.instancia.totalPiezas;

        return IconButton(
          onPressed: onCarrito,
          tooltip: 'Mi carrito',
          icon: Badge(
            isLabelVisible: piezas > 0,
            backgroundColor: GameColors.acento,
            label: Text(piezas > 99 ? '99+' : '$piezas'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }

  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $nombreUsuario',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Explora la tienda',
            style: TextStyle(
              color: GameColors.texto,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: onBuscar,
            style: const TextStyle(color: GameColors.texto),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar juegos...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionCategorias() {
    if (cargandoCategorias) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        children: [
          _chipCategoria('Todos'),
          ...categorias.map((categoria) => _chipCategoria(categoria)),
        ],
      ),
    );
  }

  Widget _chipCategoria(String categoria) {
    final bool seleccionada = categoriaSeleccionada == categoria;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(_formatearCategoria(categoria)),
        selected: seleccionada,
        onSelected: (_) {
          onCategoria(categoria);
        },
        side: BorderSide(
          color: seleccionada ? GameColors.acento : GameColors.borde,
        ),
        labelStyle: TextStyle(
          color: seleccionada ? Colors.white : GameColors.textoSecundario,
          fontWeight: seleccionada ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  String _formatearCategoria(String categoria) {
    return categoria
        .split(' ')
        .map(
          (palabra) => palabra.isEmpty
              ? palabra
              : palabra[0].toUpperCase() + palabra.substring(1),
        )
        .join(' ');
  }

  Widget _tituloProductos() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: TituloSeccion(
        busqueda.isEmpty ? 'Catálogo' : 'Resultados',
        accion: !cargandoProductos && errorProductos == null
            ? Text(
                '${productos.length} '
                '${productos.length == 1 ? 'juego' : 'juegos'}',
                style: const TextStyle(
                  color: GameColors.textoSecundario,
                  fontSize: 13,
                ),
              )
            : null,
      ),
    );
  }

  Widget _tarjetaProducto(Producto producto) {
    final bool agotado = producto.stock <= 0;

    return Material(
      color: GameColors.superficie,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          onProducto(producto);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Las portadas de Steam miden 460 x 215.
            AspectRatio(
              aspectRatio: 460 / 215,
              child: PortadaJuego(url: producto.image),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GameColors.texto,
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${producto.category} · ${producto.platform}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GameColors.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            agotado
                                ? 'Agotado'
                                : formatoPrecio(producto.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: agotado
                                  ? GameColors.textoTenue
                                  : GameColors.texto,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Agregar 1 pieza sin entrar al detalle.
                        if (puedeComprar)
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: IconButton(
                              onPressed: agotado
                                  ? null
                                  : () => onAgregarRapido(producto),
                              tooltip: 'Agregar al carrito',
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    GameColors.acento.withValues(alpha: 0.15),
                                foregroundColor: GameColors.acento,
                                disabledBackgroundColor:
                                    GameColors.superficieAlta,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_shopping_cart_rounded,
                              ),
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

  Widget _sinResultados() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 44,
            color: GameColors.textoTenue,
          ),
          const SizedBox(height: 12),
          Text(
            busqueda.isEmpty
                ? 'No hay juegos disponibles.'
                : 'No hay juegos que coincidan con "$busqueda".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorProductos() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: GameColors.textoTenue,
          ),
          const SizedBox(height: 14),
          Text(
            errorProductos!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRecargar,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
