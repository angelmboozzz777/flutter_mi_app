import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
 
// ==========================================================
// CONFIGURACIÓN DE LA API (GameStore API - FastAPI + MySQL)
// ==========================================================
 
class ApiConfig {
  // Si pruebas en un CELULAR FÍSICO, escribe aquí la IP de tu PC,
  // por ejemplo: 'http://192.168.1.50:8000'
  // Si lo dejas vacío, la dirección se elige sola según dónde corras la app.
  // También se puede pasar al correr la app, sin tocar el código:
  //   flutter run --dart-define=API_URL=http://192.168.1.50:8000
  static const String urlManual = String.fromEnvironment('API_URL');
 
  static String get baseUrl {
    if (urlManual.isNotEmpty) {
      return urlManual;
    }
 
    // Emulador de Android: 10.0.2.2 apunta a tu PC.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
 
    // Chrome (web), Windows, Linux, iOS simulator.
    return 'http://localhost:8000';
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
