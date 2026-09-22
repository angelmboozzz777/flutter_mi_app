import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import '../models/administrador.dart';
import '../models/auditor.dart';
import '../models/cliente.dart';

class AuthService {
  // URL principal de Fake Store API.
  static const String baseUrl = 'https://fakestoreapi.com';

  // ==========================================================
  // CONVERSIÓN DE DATOS
  // ==========================================================

  // Convierte cualquier valor recibido de la API a double.
  double convertirADouble(dynamic valor) {
    return double.parse(valor.toString());
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
      // 1. Enviar usuario y contraseña a la API
      // ------------------------------------------------------

      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
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
      // 2. Obtener el token
      // ------------------------------------------------------

      final Map<String, dynamic> loginData =
          jsonDecode(loginResponse.body);

      final dynamic tokenData = loginData['token'];

      if (tokenData == null) {
        throw Exception('La API no devolvió token');
      }

      final String token = tokenData.toString();

      // ------------------------------------------------------
      // 3. Consultar todos los usuarios
      // ------------------------------------------------------

      final usersResponse = await http.get(
        Uri.parse('$baseUrl/users'),
      );

      if (usersResponse.statusCode != 200) {
        throw Exception(
          'Users HTTP ${usersResponse.statusCode}',
        );
      }

      final List<dynamic> users =
          jsonDecode(usersResponse.body);

      // ------------------------------------------------------
      // 4. Buscar al usuario que inició sesión
      // ------------------------------------------------------

      Map<String, dynamic>? user;

      for (final item in users) {
        if (item['username'] == username) {
          user = Map<String, dynamic>.from(item);
          break;
        }
      }

      if (user == null) {
        throw Exception(
          'Usuario no encontrado en /users',
        );
      }

      // ------------------------------------------------------
      // 5. Obtener los datos principales
      // ------------------------------------------------------

      final int userId = int.parse(
        user['id'].toString(),
      );

      final Map<String, dynamic> name =
          Map<String, dynamic>.from(user['name']);

      final Map<String, dynamic> address =
          Map<String, dynamic>.from(user['address']);

      final Map<String, dynamic> geolocation =
          Map<String, dynamic>.from(address['geolocation']);

      // El modelo Usuario espera number como int.
      final int number = int.parse(
        address['number'].toString(),
      );

      // El modelo Usuario espera latitude y longitude como double.
      final double latitude = convertirADouble(
        geolocation['lat'],
      );

      final double longitude = convertirADouble(
        geolocation['long'],
      );

      // ======================================================
      // 6. POLIMORFISMO
      // ======================================================

      // La variable es de tipo Usuario, pero puede guardar
      // un Administrador, Auditor o Cliente.
      late Usuario usuario;

      if (userId == 1 || userId == 2) {
        // Creamos un Administrador.
        usuario = Administrador(
          id: userId,
          username: username,
          email: user['email'].toString(),
          phone: user['phone'].toString(),
          firstName: name['firstname'].toString(),
          lastName: name['lastname'].toString(),
          street: address['street'].toString(),
          number: number,
          city: address['city'].toString(),
          zipcode: address['zipcode'].toString(),
          latitude: latitude,
          longitude: longitude,
        );
      } else if (userId == 3) {
        // Creamos un Auditor.
        usuario = Auditor(
          id: userId,
          username: username,
          email: user['email'].toString(),
          phone: user['phone'].toString(),
          firstName: name['firstname'].toString(),
          lastName: name['lastname'].toString(),
          street: address['street'].toString(),
          number: number,
          city: address['city'].toString(),
          zipcode: address['zipcode'].toString(),
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        // Creamos un Cliente.
        usuario = Cliente(
          id: userId,
          username: username,
          email: user['email'].toString(),
          phone: user['phone'].toString(),
          firstName: name['firstname'].toString(),
          lastName: name['lastname'].toString(),
          street: address['street'].toString(),
          number: number,
          city: address['city'].toString(),
          zipcode: address['zipcode'].toString(),
          latitude: latitude,
          longitude: longitude,
        );
      }

      // ------------------------------------------------------
      // 7. Determinar el rol
      // ------------------------------------------------------

      final String role;

      if (userId == 1 || userId == 2) {
        role = 'Administrador';
      } else if (userId == 3) {
        role = 'Auditor';
      } else {
        role = 'Cliente';
      }

      // ------------------------------------------------------
      // 8. Regresar los datos al LoginPage
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