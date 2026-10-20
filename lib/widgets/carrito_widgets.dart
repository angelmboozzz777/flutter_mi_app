import 'package:flutter/material.dart';

import '../models/item_carrito.dart';
import '../theme/game_theme.dart';

class CarritoWidgets extends StatelessWidget {
  final List<ItemCarrito> items;
  final double total;
  final int totalPiezas;

  final void Function(ItemCarrito item, int nuevaCantidad) onCambiarCantidad;
  final void Function(ItemCarrito item) onEliminar;
  final VoidCallback onPagar;
  final VoidCallback onExplorar;

  const CarritoWidgets({
    super.key,
    required this.items,
    required this.total,
    required this.totalPiezas,
    required this.onCambiarCantidad,
    required this.onEliminar,
    required this.onPagar,
    required this.onExplorar,
  });

  bool get vacio => items.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi carrito'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: vacio
                ? _carritoVacio()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _tarjetaItem(items[index]);
                    },
                  ),
          ),
          _resumen(),
        ],
      ),
    );
  }

  // ==========================================================
  // US10 - Escenario 3: carrito vacío
  // ==========================================================

  Widget _carritoVacio() {
    // Con scroll, por si con letra grande no cabe en la pantalla.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: GameColors.superficie,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 44,
                color: GameColors.textoTenue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tu carrito está vacío, explora el catálogo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GameColors.texto,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Los juegos que agregues aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GameColors.textoSecundario,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: onExplorar,
              child: const Text('Explorar catálogo'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // US10 - Escenarios 1 y 2: cantidad y eliminar
  // ==========================================================

  Widget _tarjetaItem(ItemCarrito item) {
    return Panel(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 104,
              height: 49,
              child: PortadaJuego(url: item.producto.image, iconoSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.producto.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: GameColors.texto,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        onPressed: () => onEliminar(item),
                        tooltip: 'Quitar del carrito',
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        color: GameColors.textoSecundario,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatoPrecio(item.producto.price)} c/u',
                  style: const TextStyle(
                    color: GameColors.textoSecundario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SelectorCantidad(
                      cantidad: item.cantidad,
                      // Bajar de 1 a 0 elimina el producto.
                      onMenos: () =>
                          onCambiarCantidad(item, item.cantidad - 1),
                      onMas: () =>
                          onCambiarCantidad(item, item.cantidad + 1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formatoPrecio(item.subtotal),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: GameColors.texto,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TOTAL Y BOTÓN DE PAGO
  // ==========================================================

  Widget _resumen() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: GameColors.superficie,
        border: Border(top: BorderSide(color: GameColors.borde)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _renglonResumen(
              'Subtotal ($totalPiezas '
              '${totalPiezas == 1 ? 'artículo' : 'artículos'})',
              formatoPrecio(total),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: GameColors.texto,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                // El total se hace más chico si no cabe; nunca se corta.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatoPrecio(total),
                      style: const TextStyle(
                        color: GameColors.texto,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: BotonPrincipal(
                texto: 'Proceder al pago',
                icono: Icons.lock_outline,
                // Desactivado si el carrito está vacío.
                onPressed: vacio ? null : onPagar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renglonResumen(String titulo, String valor) {
    const TextStyle estilo = TextStyle(
      color: GameColors.textoSecundario,
      fontSize: 14,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: estilo,
          ),
        ),
        const SizedBox(width: 12),
        Text(valor, style: estilo),
      ],
    );
  }
}

// ==========================================================
// SELECTOR DE CANTIDAD (se usa en el carrito y en el detalle)
// ==========================================================

class SelectorCantidad extends StatelessWidget {
  final int cantidad;
  final VoidCallback? onMenos;
  final VoidCallback? onMas;

  const SelectorCantidad({
    super.key,
    required this.cantidad,
    required this.onMenos,
    required this.onMas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GameColors.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _boton(Icons.remove, onMenos),
          SizedBox(
            width: 32,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GameColors.texto,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _boton(Icons.add, onMas),
        ],
      ),
    );
  }

  Widget _boton(IconData icono, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icono,
          size: 16,
          color: onTap == null
              ? GameColors.textoTenue
              : GameColors.texto,
        ),
      ),
    );
  }
}

// ==========================================================
// DIÁLOGO DE PAGO (simulación)
// ==========================================================

Future<bool?> mostrarDialogoPago(
  BuildContext context,
  double total,
  int piezas,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar compra'),
        content: Text(
          'Vas a pagar ${formatoPrecio(total)} por '
          '$piezas ${piezas == 1 ? 'artículo' : 'artículos'}.\n\n'
          'Esta es una simulación: no se hará ningún cargo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pagar'),
          ),
        ],
      );
    },
  );
}
