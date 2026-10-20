import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/item_carrito.dart';
import '../models/producto.dart';
import 'api_config.dart';

// ==========================================================
// CARRITO (US09 / US10)
//
// Manejador de estado: los artículos viven en memoria mientras
// la sesión está activa (una sola instancia para toda la app).
// Cada cambio se refleja primero en la pantalla y después se
// sincroniza con la API:
//   - primer artículo  -> POST   /carts
//   - sumar / cambiar  -> PUT    /carts/{id}
//   - quitar artículo  -> DELETE /carts/{id}/products/{gameId}
// Las pantallas escuchan los cambios con ListenableBuilder.
// ==========================================================

class CarritoService extends ChangeNotifier {
  CarritoService._();

  static final CarritoService instancia = CarritoService._();

  static String get baseUrl => ApiConfig.baseUrl;

  final List<ItemCarrito> _items = [];

  // id del carrito en la API; null hasta el primer POST.
  int? _cartId;

  // Las peticiones se mandan una por una, en el orden en que ocurren.
  Future<void> _cola = Future.value();

  // Cambia cada vez que se empieza un carrito nuevo (cerrar sesión,
  // iniciar sesión o pagar). Así, una respuesta que llega tarde de un
  // carrito anterior no se mezcla con el nuevo.
  int _sesion = 0;

  // ----------------------------------------------------------
  // CONSULTAS (los cálculos se hacen sobre la lista local)
  // ----------------------------------------------------------

  List<ItemCarrito> get items => List.unmodifiable(_items);

  bool get estaVacio => _items.isEmpty;

  int get totalPiezas {
    int piezas = 0;
    for (final item in _items) {
      piezas += item.cantidad;
    }
    return piezas;
  }

  double get total {
    double suma = 0;
    for (final item in _items) {
      suma += item.producto.price * item.cantidad;
    }
    return double.parse(suma.toStringAsFixed(2));
  }

  int cantidadDe(int productoId) {
    for (final item in _items) {
      if (item.producto.id == productoId) return item.cantidad;
    }
    return 0;
  }

  // Cuántas piezas más se pueden agregar sin pasar el stock.
  int disponiblePara(Producto producto) {
    final int restante = producto.stock - cantidadDe(producto.id);
    return restante < 0 ? 0 : restante;
  }

  // ----------------------------------------------------------
  // US09 - AGREGAR
  // ----------------------------------------------------------

  // Si el producto ya está en el carrito, suma la cantidad
  // en lugar de crear un registro duplicado.
  Future<void> agregar(Producto producto, int cantidad) async {
    if (cantidad <= 0) {
      throw ArgumentError('La cantidad debe ser mayor a cero');
    }

    if (cantidad > disponiblePara(producto)) {
      throw Exception(_mensajeStock(producto));
    }

    await _cambiarYSincronizar(
      () {
        final int indice = _indiceDe(producto.id);
        if (indice >= 0) {
          _items[indice].cantidad += cantidad;
        } else {
          _items.add(ItemCarrito(producto: producto, cantidad: cantidad));
        }
      },
      _guardarEnApi,
    );
  }

  // ----------------------------------------------------------
  // US10 - MODIFICAR Y ELIMINAR
  // ----------------------------------------------------------

  // Cambia la cantidad; si llega a cero, quita el producto.
  Future<void> cambiarCantidad(int productoId, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      return eliminar(productoId);
    }

    final int indice = _indiceDe(productoId);
    if (indice < 0) return;

    final Producto producto = _items[indice].producto;
    if (nuevaCantidad > producto.stock) {
      throw Exception(_mensajeStock(producto));
    }

    await _cambiarYSincronizar(
      () {
        final int i = _indiceDe(productoId);
        if (i >= 0) _items[i].cantidad = nuevaCantidad;
      },
      _guardarEnApi,
    );
  }

  Future<void> eliminar(int productoId) async {
    if (_indiceDe(productoId) < 0) return;

    await _cambiarYSincronizar(
      () => _items.removeWhere((item) => item.producto.id == productoId),
      () => _quitarEnApi(productoId),
    );
  }

  // Quita un producto solo en el dispositivo. Se usa cuando el juego
  // se eliminó del catálogo: la API ya lo borró de los carritos.
  void quitarLocal(int productoId) {
    final int antes = _items.length;
    _items.removeWhere((item) => item.producto.id == productoId);
    if (_items.length != antes) notifyListeners();
  }

  // Si el administrador edita un juego (precio, título...), el
  // carrito usa los datos nuevos para calcular el total.
  void actualizarProducto(Producto producto) {
    final int indice = _indiceDe(producto.id);
    if (indice < 0) return;

    final int cantidad = _items[indice].cantidad;
    _items[indice] = ItemCarrito(producto: producto, cantidad: cantidad);
    notifyListeners();
  }

  // Simulación de pago: el carrito se queda en la API como pedido
  // y en el dispositivo se empieza uno nuevo.
  void finalizarCompra() {
    _reiniciar();
  }

  // Al iniciar o cerrar sesión se olvida todo.
  void limpiar() {
    _reiniciar();
  }

  void _reiniciar() {
    _sesion++;
    _items.clear();
    _cartId = null;
    _cola = Future.value();
    notifyListeners();
  }

  // ----------------------------------------------------------
  // SINCRONIZACIÓN CON LA API
  // ----------------------------------------------------------

  // Aplica el cambio local al instante (total en tiempo real) y
  // luego manda la petición. Si la API falla, se deshace el cambio.
  Future<void> _cambiarYSincronizar(
    VoidCallback cambioLocal,
    Future<void> Function() peticion,
  ) {
    final int sesion = _sesion;
    final List<ItemCarrito> respaldo =
        _items.map((item) => item.copia()).toList();

    cambioLocal();
    notifyListeners();

    final Future<void> tarea = _cola.then((_) {
      // El carrito se reinició mientras esperaba su turno.
      if (sesion != _sesion) return Future.value();
      return peticion();
    });

    // La cola sigue aunque esta petición falle.
    _cola = tarea.catchError((_) {});

    return tarea.catchError((Object e) {
      // Solo se deshace si seguimos en el mismo carrito.
      if (sesion == _sesion) {
        _items
          ..clear()
          ..addAll(respaldo);
        notifyListeners();
      }
      throw e;
    });
  }

  // POST la primera vez; PUT con la lista completa después.
  Future<void> _guardarEnApi() async {
    final int sesion = _sesion;

    final String body = jsonEncode({
      'products': _items.map((item) => item.toJson()).toList(),
    });

    final http.Response response;

    if (_cartId == null) {
      response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: ApiConfig.headers(conToken: true),
        body: body,
      );
    } else {
      response = await http.put(
        Uri.parse('$baseUrl/carts/$_cartId'),
        headers: ApiConfig.headers(conToken: true),
        body: body,
      );
    }

    // La respuesta llegó cuando ya se había empezado otro carrito.
    if (sesion != _sesion) return;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'No se pudo actualizar el carrito: ${ApiConfig.detalleError(response)}',
      );
    }

    final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
    _cartId = int.parse(data['id'].toString());
  }

  Future<void> _quitarEnApi(int productoId) async {
    // Si el carrito nunca llegó a la API, no hay nada que borrar allá.
    if (_cartId == null) return;

    final int sesion = _sesion;

    final response = await http.delete(
      Uri.parse('$baseUrl/carts/$_cartId/products/$productoId'),
      headers: ApiConfig.headers(conToken: true),
    );

    if (sesion != _sesion) return;

    // 404: el juego ya no estaba en el carrito de la API; localmente
    // ya se quitó, así que no hay nada que corregir.
    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception(
        'No se pudo quitar el producto: ${ApiConfig.detalleError(response)}',
      );
    }
  }

  int _indiceDe(int productoId) {
    return _items.indexWhere((item) => item.producto.id == productoId);
  }

  String _mensajeStock(Producto producto) {
    final int enCarrito = cantidadDe(producto.id);

    if (producto.stock <= 0) {
      return '"${producto.title}" está agotado';
    }

    return enCarrito > 0
        ? 'Solo hay ${producto.stock} en stock y ya tienes '
            '$enCarrito en el carrito'
        : 'Solo hay ${producto.stock} en stock';
  }
}
