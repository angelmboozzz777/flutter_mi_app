import 'package:flutter/material.dart';

import '../models/carrito_registrado.dart';
import '../theme/game_theme.dart';
import 'consulta_widgets.dart';

class ResumenCarritos {
  final int carritos;
  final int piezas;
  final double monto;
  final int clientes;

  const ResumenCarritos({
    required this.carritos,
    required this.piezas,
    required this.monto,
    required this.clientes,
  });
}

class CarritosGlobalesWidgets extends StatelessWidget {
  final List<CarritoDetallado> carritos;
  final int totalCarritos;
  final ResumenCarritos resumen;

  final bool cargando;
  final String? error;

  final String busqueda;
  final String filtro;

  final Function(String) onBuscar;
  final Function(String) onFiltro;
  final Future<void> Function() onRecargar;

  const CarritosGlobalesWidgets({
    super.key,
    required this.carritos,
    required this.totalCarritos,
    required this.resumen,
    required this.cargando,
    required this.error,
    required this.busqueda,
    required this.filtro,
    required this.onBuscar,
    required this.onFiltro,
    required this.onRecargar,
  });

  static const Map<String, String> nombresFiltro = {
    'todos': 'Todos',
    'con_articulos': 'Con artículos',
    'vacios': 'Vacíos',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de carritos'),
        actions: [
          IconButton(
            onPressed: cargando ? null : onRecargar,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    if (cargando && totalCarritos == 0) {
      return const EstadoCargando(mensaje: 'Cargando historial de carritos...');
    }

    if (error != null && totalCarritos == 0) {
      return EstadoError(mensaje: error!, onReintentar: onRecargar);
    }

    return RefreshIndicator(
      onRefresh: onRecargar,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _encabezado()),
          SliverToBoxAdapter(child: _filtros()),
          if (cargando)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (carritos.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _sinResultados())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList.separated(
                itemCount: carritos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return TarjetaCarritoGlobal(detallado: carritos[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Monitoreo de compras',
                  style: TextStyle(
                    color: GameColors.texto,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InsigniaSoloLectura(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Carritos de todos los clientes, del más reciente al más antiguo.',
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Indicador(
                  valor: '${resumen.carritos}',
                  etiqueta: 'Carritos',
                  icono: Icons.shopping_cart_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Indicador(
                  valor: '${resumen.piezas}',
                  etiqueta: 'Artículos',
                  icono: Icons.videogame_asset_outlined,
                  color: GameColors.advertencia,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Indicador(
                  valor: formatoPrecio(resumen.monto),
                  etiqueta: 'Monto total',
                  icono: Icons.payments_outlined,
                  color: GameColors.exito,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Indicador(
                  valor: '${resumen.clientes}',
                  etiqueta: 'Clientes distintos',
                  icono: Icons.people_outline,
                  color: GameColors.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onBuscar,
            style: const TextStyle(color: GameColors.texto),
            decoration: const InputDecoration(
              hintText: 'Buscar por carrito, usuario o ID de usuario...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: nombresFiltro.entries.map((entrada) {
          final bool elegido = filtro == entrada.key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entrada.value),
              selected: elegido,
              onSelected: (_) => onFiltro(entrada.key),
              side: BorderSide(
                color: elegido ? GameColors.acento : GameColors.borde,
              ),
              labelStyle: TextStyle(
                color: elegido ? Colors.white : GameColors.textoSecundario,
                fontWeight: elegido ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
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
            Icons.remove_shopping_cart_outlined,
            size: 44,
            color: GameColors.textoTenue,
          ),
          const SizedBox(height: 12),
          Text(
            totalCarritos == 0
                ? 'Todavía no hay carritos registrados.'
                : 'Ningún carrito coincide con la búsqueda.',
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
}

// ==========================================================
// Tarjeta de un carrito. Escenario 1: id, fecha y dueño.
// Escenario 3: al tocarla se despliegan sus artículos.
// ==========================================================

class TarjetaCarritoGlobal extends StatefulWidget {
  final CarritoDetallado detallado;

  const TarjetaCarritoGlobal({super.key, required this.detallado});

  @override
  State<TarjetaCarritoGlobal> createState() => _TarjetaCarritoGlobalState();
}

class _TarjetaCarritoGlobalState extends State<TarjetaCarritoGlobal> {
  bool abierta = false;

  @override
  Widget build(BuildContext context) {
    final detallado = widget.detallado;
    final carrito = detallado.carrito;
    final bool vacio = carrito.articulos.isEmpty;

    return Material(
      color: GameColors.superficie,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => abierta = !abierta),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: abierta
                  ? GameColors.acento.withValues(alpha: 0.5)
                  : GameColors.borde,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GameColors.acento.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: GameColors.acento,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carrito #${carrito.id}',
                          style: const TextStyle(
                            color: GameColors.texto,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: GameColors.textoTenue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                fechaCorta(carrito.fecha),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: GameColors.textoSecundario,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pegado a la derecha; si no cabe se hace más chico.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatoPrecio(detallado.total),
                        style: const TextStyle(
                          color: GameColors.texto,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dueño del carrito.
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorDeRol(detallado.dueno?.rol ?? 'user')
                        .withValues(alpha: 0.16),
                    child: Text(
                      detallado.dueno?.iniciales ?? '?',
                      style: TextStyle(
                        color: colorDeRol(detallado.dueno?.rol ?? 'user'),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detallado.dueno == null
                          ? 'Usuario ID ${carrito.userId}'
                          : '${detallado.nombreDueno} · @${detallado.dueno!.usuario} · ID ${carrito.userId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GameColors.texto,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Si no caben en un renglón, "Ver artículos" baja al siguiente.
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Etiqueta(
                      texto: vacio
                          ? 'Vacío'
                          : '${carrito.totalPiezas} '
                                '${carrito.totalPiezas == 1 ? 'pieza' : 'piezas'}'
                                ' · ${carrito.articulos.length} '
                                '${carrito.articulos.length == 1 ? 'juego' : 'juegos'}',
                      icono: Icons.videogame_asset_outlined,
                      color: vacio
                          ? GameColors.textoTenue
                          : GameColors.advertencia,
                    ),
                    TextoDesplegar(
                      abierta: abierta,
                      textoAbrir: 'Ver artículos',
                      textoCerrar: 'Ocultar',
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: abierta
                    ? _articulos(detallado)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articulos(CarritoDetallado detallado) {
    if (detallado.articulos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'Este carrito no tiene artículos.',
          style: TextStyle(color: GameColors.textoSecundario, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(
          color: GameColors.superficieAlta,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            for (int i = 0; i < detallado.articulos.length; i++) ...[
              if (i > 0) const Divider(),
              _articulo(detallado.articulos[i]),
            ],
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  const Text(
                    'Total del carrito',
                    style: TextStyle(
                      color: GameColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatoPrecio(detallado.total),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: GameColors.texto,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _articulo(ArticuloDetallado articulo) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 64,
              height: 30,
              child: articulo.existe
                  ? PortadaJuego(url: articulo.producto!.image, iconoSize: 16)
                  : Container(
                      color: GameColors.superficie,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: GameColors.textoTenue,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: articulo.existe
                        ? GameColors.texto
                        : GameColors.textoTenue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  articulo.existe
                      ? 'ID ${articulo.articulo.gameId} · ${articulo.articulo.cantidad} × ${formatoPrecio(articulo.producto!.price)}'
                      : 'ID ${articulo.articulo.gameId} · ${articulo.articulo.cantidad} pzas · ya no está en el catálogo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GameColors.textoSecundario,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            articulo.existe ? formatoPrecio(articulo.subtotal) : '—',
            style: const TextStyle(
              color: GameColors.texto,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
