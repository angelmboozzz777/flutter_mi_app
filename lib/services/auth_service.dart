import 'dart:convert';
 
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
 
import '../models/usuario.dart';
import '../models/administrador.dart';
import '../models/auditor.dart';
import '../models/cliente.dart';
import 'api_config.dart';
import 'carrito_service.dart';
 
class AuthService {
  // Ahora se usa GameStore API (FastAPI + MySQL) en lugar de Fake Store API.
  static String get baseUrl => ApiConfig.baseUrl;
 
  // ==========================================================
  // CONVERSIÓN DE DATOS
  // ==========================================================
 
  // Convierte cualquier valor recibido de la API a double.
  double convertirADouble(dynamic valor) {
    return double.tryParse(valor.toString()) ?? 0.0;
  }
 
  // Si el texto viene vacío o nulo, devuelve un valor por defecto.
  String _texto(dynamic valor, String porDefecto) {
    final String texto = (valor ?? '').toString().trim();
    return texto.isEmpty ? porDefecto : texto;
  }
 
  // ==========================================================
  // INICIO DE SESIÓN
  // ==========================================================
 
  Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      // ------------------------------------------------------
      // 1. Enviar usuario (o correo) y contraseña a la API
      // ------------------------------------------------------
 
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: ApiConfig.headers(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
 
      // Si las credenciales son incorrectas, regresamos null.
      if (loginResponse.statusCode == 401) {
        return null;
      }
 
      // Validamos que la respuesta sea correcta.
      if (loginResponse.statusCode != 200 &&
          loginResponse.statusCode != 201) {
        throw Exception(
          'Login HTTP ${loginResponse.statusCode}',
        );
      }
 
      // ------------------------------------------------------
      // 2. Obtener el token y los datos del usuario.
      //    La API ya devuelve ambos en la misma respuesta,
      //    por eso ya no hace falta consultar /users.
      // ------------------------------------------------------
 
      final Map<String, dynamic> loginData =
          jsonDecode(utf8.decode(loginResponse.bodyBytes));
 
      final dynamic tokenData = loginData['token'];
 
      if (tokenData == null) {
        throw Exception('La API no devolvió token');
      }
 
      final String token = tokenData.toString();
 
      // Guardamos el token en memoria para las peticiones protegidas
      // (crear, editar y eliminar productos).
      ApiConfig.token = token;

      // Cada sesión empieza con su propio carrito.
      CarritoService.instancia.limpiar();
 
      final Map<String, dynamic> userApi =
          Map<String, dynamic>.from(loginData['user']);
 
      // ------------------------------------------------------
      // 3. Obtener los datos principales
      // ------------------------------------------------------
 
      final int userId = int.parse(
        userApi['id'].toString(),
      );
 
      // Rol que guarda la base de datos: admin, auditor o user.
      final String rolApi =
          (userApi['role'] ?? 'user').toString().toLowerCase();
 
      final Map<String, dynamic> nameApi =
          Map<String, dynamic>.from(userApi['name'] ?? {});
 
      final Map<String, dynamic> addressApi =
          Map<String, dynamic>.from(userApi['address'] ?? {});
 
      // Valores por defecto para campos que pueden venir vacíos.
      final String nombreUsuario = _texto(userApi['username'], username);
      final String email =
          _texto(userApi['email'], 'sin-correo@gamestore.com');
      final String phone = _texto(userApi['phone'], '0000000000');
      final String firstName = _texto(nameApi['firstname'], 'Sin nombre');
      final String lastName = _texto(nameApi['lastname'], 'Sin apellido');
      final String street = _texto(addressApi['street'], 'Sin calle');
      final String city = _texto(addressApi['city'], 'Sin ciudad');
      final String zipcode = _texto(addressApi['zipcode'], '00000');
 
      // El modelo Usuario espera number como int.
      final int number = int.tryParse(
            (addressApi['number'] ?? '').toString(),
          ) ??
          1;
 
      // La API no maneja geolocalización, así que usamos 0.0.
      const double latitude = 0.0;
      const double longitude = 0.0;
 
      // ======================================================
      // 4. POLIMORFISMO
      // ======================================================
 
      // El rol viene de la columna "role" de la tabla users:
      //   admin   -> Administrador
      //   auditor -> Auditor
      //   user    -> Cliente
      late Usuario usuario;
 
      final String role;
 
      if (rolApi == 'admin') {
        role = 'Administrador';
 
        usuario = Administrador(
          id: userId,
          username: nombreUsuario,
          email: email,
          phone: phone,
          firstName: firstName,
          lastName: lastName,
          street: street,
          number: number,
          city: city,
          zipcode: zipcode,
          latitude: latitude,
          longitude: longitude,
        );
      } else if (rolApi == 'auditor') {
        role = 'Auditor';
 
        usuario = Auditor(
          id: userId,
          username: nombreUsuario,
          email: email,
          phone: phone,
          firstName: firstName,
          lastName: lastName,
          street: street,
          number: number,
          city: city,
          zipcode: zipcode,
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        role = 'Cliente';
 
        usuario = Cliente(
          id: userId,
          username: nombreUsuario,
          email: email,
          phone: phone,
          firstName: firstName,
          lastName: lastName,
          street: street,
          number: number,
          city: city,
          zipcode: zipcode,
          latitude: latitude,
          longitude: longitude,
        );
      }
 
      // ------------------------------------------------------
      // 5. Mapa del usuario con la misma forma que usaba
      //    Fake Store API, para que las pantallas que lo
      //    leen (perfil, etc.) sigan funcionando igual.
      // ------------------------------------------------------
 
      final Map<String, dynamic> user = {
        'id': userId,
        'username': nombreUsuario,
        'email': email,
        'phone': phone,
        'name': {
          'firstname': firstName,
          'lastname': lastName,
        },
        'address': {
          'city': city,
          'street': street,
          'number': number,
          'zipcode': zipcode,
          'geolocation': {
            'lat': '0',
            'long': '0',
          },
        },
      };
 
      // ------------------------------------------------------
      // 6. Regresar los datos al LoginPage
      // ------------------------------------------------------
 
      return {
        'token': token,
        'userId': userId,
        'role': role,
        'usuario': usuario,
        'user': user,
      };
    } catch (e) {
      // Mostramos el error en la consola.
      debugPrint('ERROR REAL: $e');
 
      // Enviamos el error nuevamente al LoginPage.
      rethrow;
    }
  }
}
 