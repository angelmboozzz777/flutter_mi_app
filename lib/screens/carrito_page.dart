import 'package:flutter/material.dart';

import '../models/item_carrito.dart';
import '../services/carrito_service.dart';
import '../widgets/carrito_widgets.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  final CarritoService carrito = CarritoService.instancia;

  // ==========================================================
  // MODIFICAR CANTIDAD (PUT)
  // ==========================================================

  Future<void> cambiarCantidad(ItemCarrito item, int nuevaCantidad) async {
    try {
      await carrito.cambiarCantidad(item.producto.id, nuevaCantidad);
    } catch (e) {
      mostrarError(e);
    }
  }

  // ==========================================================
  // ELIMINAR PRODUCTO (DELETE)
  // ==========================================================

  Future<void> eliminar(ItemCarrito item) async {
    try {
      await carrito.eliminar(item.producto.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.producto.title}" se quitó del carrito'),
        ),
      );
    } catch (e) {
      mostrarError(e);
    }
  }

  // ==========================================================
  // PAGO (simulación)
  // ==========================================================

  Future<void> procederAlPago() async {
    if (carrito.estaVacio) return;

    final double total = carrito.total;
    final int piezas = carrito.totalPiezas;

    final bool? confirmar = await mostrarDialogoPago(context, total, piezas);

    if (confirmar != true || !mounted) return;

    carrito.finalizarCompra();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Compra simulada con éxito! Total: \$${total.toStringAsFixed(2)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void mostrarError(Object e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
  }

  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // Se vuelve a dibujar cada vez que cambia el carrito.
    return ListenableBuilder(
      listenable: carrito,
      builder: (context, _) {
        return CarritoWidgets(
          items: carrito.items,
          total: carrito.total,
          totalPiezas: carrito.totalPiezas,
          onCambiarCantidad: cambiarCantidad,
          onEliminar: eliminar,
          onPagar: procederAlPago,
          onExplorar: () => Navigator.pop(context),
        );
      },
    );
  }
}
