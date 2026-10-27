import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/carrito_registrado.dart';
import '../models/producto.dart';
import '../models/usuario_registrado.dart';
import 'api_config.dart';

// ==========================================================
// CONSULTAS DE SOLO LECTURA (US11 y US12)
// Solo las pueden usar el Administrador y el Auditor; la API
// también lo valida y responde 403 a cualquier otro rol.
// ==========================================================

class Permisos {
  static bool puedeConsultarTodo(String rol) =>
      rol == 'Administrador' || rol == 'Auditor';
}

class ConsultaService {
  static String get baseUrl => ApiConfig.baseUrl;

  // En el plan gratis de Render la API "despierta" en ~50 segundos.
  static const Duration tiempoMaximo = Duration(seconds: 70);

  // ----------------------------------------------------------
  // US11 - GET /users
  // ----------------------------------------------------------

  Future<List<UsuarioRegistrado>> obtenerUsuarios() async {
    final List<dynamic> data = await _getLista('/users', conToken: true);
    return data
        .whereType<Map>()
        .map(
          (item) => UsuarioRegistrado.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ----------------------------------------------------------
  // US12 - GET /carts (global para Admin y Auditor)
  // ----------------------------------------------------------

  Future<List<CarritoRegistrado>> obtenerCarritos() async {
    final List<dynamic> data = await _getLista('/carts', conToken: true);
    return data
        .whereType<Map>()
        .map(
          (item) => CarritoRegistrado.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // Catálogo como mapa id -> producto, para cruzar con los carritos.
  Future<Map<int, Producto>> obtenerCatalogo() async {
    final List<dynamic> data = await _getLista('/games');
    final Map<int, Producto> catalogo = {};
    for (final item in data.whereType<Map>()) {
      try {
        final producto = Producto.fromJson(Map<String, dynamic>.from(item));
        catalogo[producto.id] = producto;
      } catch (_) {
        // Un juego con datos inválidos no debe romper toda la pantalla.
      }
    }
    return catalogo;
  }

  // Carga carritos, catálogo y usuarios al mismo tiempo y los cruza.
  Future<List<CarritoDetallado>> obtenerCarritosDetallados() async {
    final resultados = await Future.wait([
      obtenerCarritos(),
      obtenerCatalogo(),
      // Si fallara la lista de usuarios, igual se muestran los carritos
      // con el id del dueño.
      obtenerUsuarios().catchError((_) => <UsuarioRegistrado>[]),
    ]);

    final carritos = resultados[0] as List<CarritoRegistrado>;
    final catalogo = resultados[1] as Map<int, Producto>;
    final usuarios = {
      for (final usuario in resultados[2] as List<UsuarioRegistrado>)
        usuario.id: usuario,
    };

    return carritos
        .map((carrito) => CarritoDetallado.cruzar(carrito, catalogo, usuarios))
        .toList();
  }

  // ----------------------------------------------------------
  // Petición GET con mensajes de error claros
  // ----------------------------------------------------------

  Future<List<dynamic>> _getLista(String ruta, {bool conToken = false}) async {
    final http.Response response;

    try {
      response = await http
          .get(
            Uri.parse('$baseUrl$ruta'),
            headers: ApiConfig.headers(conToken: conToken),
          )
          .timeout(tiempoMaximo);
    } on TimeoutException {
      throw Exception(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
      );
    } catch (_) {
      throw Exception('No hay conexión con el servidor. Revisa tu internet.');
    }

    if (response.statusCode == 401) {
      throw Exception('Tu sesión expiró. Vuelve a iniciar sesión.');
    }

    if (response.statusCode == 403) {
      throw Exception('No tienes permiso para ver esta información.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo cargar la información: ${ApiConfig.detalleError(response)}',
      );
    }

    final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is! List) {
      throw Exception(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }
    return data;
  }
}
