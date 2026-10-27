// ==========================================================
// US12 - Carrito tal como lo devuelve GET /carts
// { id, userId, date: "2026-10-20", products: [{gameId, quantity}] }
// ==========================================================

import 'producto.dart';
import 'usuario_registrado.dart';

int _entero(dynamic valor) => int.tryParse((valor ?? '').toString()) ?? 0;

class ArticuloCarrito {
  final int gameId;
  final int cantidad;

  const ArticuloCarrito({required this.gameId, required this.cantidad});

  factory ArticuloCarrito.fromJson(dynamic json) {
    final datos = json is Map
        ? Map<String, dynamic>.from(json)
        : <String, dynamic>{};
    // Algunas APIs lo llaman productId (Fake Store); la nuestra, gameId.
    return ArticuloCarrito(
      gameId: _entero(datos['gameId'] ?? datos['productId']),
      cantidad: _entero(datos['quantity']),
    );
  }
}

class CarritoRegistrado {
  final int id;
  final int userId;
  final DateTime? fecha;
  final List<ArticuloCarrito> articulos;

  const CarritoRegistrado({
    required this.id,
    required this.userId,
    required this.fecha,
    required this.articulos,
  });

  factory CarritoRegistrado.fromJson(Map<String, dynamic> json) {
    final dynamic productos = json['products'];
    return CarritoRegistrado(
      id: _entero(json['id']),
      userId: _entero(json['userId']),
      fecha: DateTime.tryParse((json['date'] ?? '').toString()),
      articulos: productos is List
          ? productos.map(ArticuloCarrito.fromJson).toList()
          : const [],
    );
  }

  int get totalPiezas =>
      articulos.fold(0, (suma, articulo) => suma + articulo.cantidad);
}

// ==========================================================
// Cruce de datos (reto de US12): el carrito solo trae ids, así
// que se unen con el catálogo (GET /games) para mostrar el
// título y el precio, y con GET /users para mostrar al dueño.
// ==========================================================

class ArticuloDetallado {
  final ArticuloCarrito articulo;
  final Producto? producto; // null si el juego ya se eliminó

  const ArticuloDetallado({required this.articulo, required this.producto});

  String get titulo => producto?.title ?? 'Juego #${articulo.gameId}';

  bool get existe => producto != null;

  double get subtotal => double.parse(
    ((producto?.price ?? 0) * articulo.cantidad).toStringAsFixed(2),
  );
}

class CarritoDetallado {
  final CarritoRegistrado carrito;
  final UsuarioRegistrado? dueno; // null si no se pudo cruzar
  final List<ArticuloDetallado> articulos;

  const CarritoDetallado({
    required this.carrito,
    required this.dueno,
    required this.articulos,
  });

  factory CarritoDetallado.cruzar(
    CarritoRegistrado carrito,
    Map<int, Producto> catalogo,
    Map<int, UsuarioRegistrado> usuarios,
  ) {
    return CarritoDetallado(
      carrito: carrito,
      dueno: usuarios[carrito.userId],
      articulos: carrito.articulos
          .map(
            (articulo) => ArticuloDetallado(
              articulo: articulo,
              producto: catalogo[articulo.gameId],
            ),
          )
          .toList(),
    );
  }

  double get total => double.parse(
    articulos
        .fold<double>(0, (suma, articulo) => suma + articulo.subtotal)
        .toStringAsFixed(2),
  );

  String get nombreDueno =>
      dueno?.nombreVisible ?? 'Usuario #${carrito.userId}';

  // Para el buscador: carrito, id de usuario, nombre o usuario.
  bool coincideCon(String texto) {
    final buscado = texto.toLowerCase().replaceAll('#', '').trim();
    return carrito.id.toString() == buscado ||
        carrito.userId.toString() == buscado ||
        nombreDueno.toLowerCase().contains(buscado) ||
        (dueno?.usuario.toLowerCase().contains(buscado) ?? false);
  }
}
