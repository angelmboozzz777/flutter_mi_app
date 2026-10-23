import 'dart:convert';

import 'package:http/http.dart' as http;
 
// ==========================================================
// CONFIGURACIÓN DE LA API (GameStore API - FastAPI + MongoDB Atlas)
// ==========================================================

class ApiConfig {
  // API publicada en Render. Funciona en emulador, celular físico y web.
  // Plan gratis: si nadie la usa en 15 min se duerme y la primera
  // petición tarda ~50 segundos en responder.
  static const String urlRender = 'https://gamestore-api-bypj.onrender.com';

  // Para usar la API corriendo en tu PC en lugar de Render:
  //   flutter run --dart-define=API_URL=http://10.0.2.2:8000   (emulador Android)
  //   flutter run --dart-define=API_URL=http://localhost:8000  (Chrome / Windows)
  static const String urlManual = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (urlManual.isNotEmpty) {
      return urlManual;
    }
    return urlRender;
  }
 
  // Token de la sesión actual. Lo guarda AuthService al iniciar sesión.
  static String? token;
 
  // Headers para las peticiones. conToken: true agrega el token.
  static Map<String, String> headers({bool conToken = false}) {
    return {
      'Content-Type': 'application/json',
      if (conToken && token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Lee el mensaje de error que manda FastAPI en "detail".
  // En errores de validación (422) "detail" es una lista.
  static String detalleError(http.Response response) {
    try {
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      final dynamic detail = data is Map ? data['detail'] : null;

      if (detail is List && detail.isNotEmpty) {
        final dynamic primero = detail.first;
        final String campo = primero is Map && primero['loc'] is List
            ? (primero['loc'] as List).last.toString()
            : '';
        final String mensaje =
            primero is Map ? primero['msg'].toString() : primero.toString();
        return campo.isEmpty ? mensaje : '$campo: $mensaje';
      }

      if (detail != null) {
        return detail.toString();
      }
    } catch (_) {
      // La respuesta no era JSON.
    }

    return 'HTTP ${response.statusCode}';
  }
}
