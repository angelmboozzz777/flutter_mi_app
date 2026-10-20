import 'producto.dart';

// Un renglón del carrito: el producto y cuántas piezas lleva.
class ItemCarrito {
  final Producto producto;
  int _cantidad;

  ItemCarrito({
    required this.producto,
    required int cantidad,
  }) : _cantidad = 1 {
    this.cantidad = cantidad;
  }

  int get cantidad => _cantidad;

  set cantidad(int value) {
    if (value < 1) {
      throw ArgumentError('La cantidad debe ser al menos 1');
    }
    _cantidad = value;
  }

  // Precio por cantidad, redondeado a dos decimales.
  double get subtotal =>
      double.parse((producto.price * _cantidad).toStringAsFixed(2));

  // Formato que espera la API en /carts.
  Map<String, dynamic> toJson() {
    return {
      'gameId': producto.id,
      'quantity': _cantidad,
    };
  }

  ItemCarrito copia() {
    return ItemCarrito(producto: producto, cantidad: _cantidad);
  }
}
