import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class AuthService {
  // URL de la Fake Store API.
  static const String baseUrl = 'https://fakestoreapi.com';

  // Método encargado de realizar el inicio de sesión.
  Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      // Enviamos usuario y contraseña al endpoint de login.
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

      // La API puede devolver 200 o 201 cuando el login es correcto.
      if (loginResponse.statusCode != 200 &&
          loginResponse.statusCode != 201) {
        throw Exception(
          'Login HTTP ${loginResponse.statusCode}',
        );
      }

      // Obtenemos el token de acceso.
      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['token'];

      if (token == null) {
        throw Exception('La API no devolvió token');
      }

      // Consultamos /users para obtener la información completa.
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

      // Buscamos al usuario que inició sesión.
      dynamic user;

      for (final item in users) {
        if (item['username'] == username) {
          user = item;
          break;
        }
      }

      if (user == null) {
        throw Exception('Usuario no encontrado en /users');
      }

      // Obtenemos el ID que viene desde la API.
      final int userId = user['id'];

      // ======================================================
      // POLIMORFISMO
      // ======================================================
      // Creamos un objeto diferente dependiendo del ID.
      // Todos pertenecen al tipo Usuario, pero cada clase
      // tiene su propio comportamiento.
      late Usuario usuario;

      if (userId == 1 || userId == 2) {
        usuario = Administrador(
          id: userId,
          username: username,
          email: user['email'],
          phone: user['phone'],
          firstName: user['name']['firstname'],
          lastName: user['name']['lastname'],
          street: user['address']['street'],
          number: user['address']['number'],
          city: user['address']['city'],
          zipcode: user['address']['zipcode'],
          latitude: user['address']['geolocation']['lat'],
          longitude: user['address']['geolocation']['long'],
        );
      } else if (userId == 3) {
        usuario = Auditor(
          id: userId,
          username: username,
          email: user['email'],
          phone: user['phone'],
          firstName: user['name']['firstname'],
          lastName: user['name']['lastname'],
          street: user['address']['street'],
          number: user['address']['number'],
          city: user['address']['city'],
          zipcode: user['address']['zipcode'],
          latitude: user['address']['geolocation']['lat'],
          longitude: user['address']['geolocation']['long'],
        );
      } else {
        usuario = Cliente(
          id: userId,
          username: username,
          email: user['email'],
          phone: user['phone'],
          firstName: user['name']['firstname'],
          lastName: user['name']['lastname'],
          street: user['address']['street'],
          number: user['address']['number'],
          city: user['address']['city'],
          zipcode: user['address']['zipcode'],
          latitude: user['address']['geolocation']['lat'],
          longitude: user['address']['geolocation']['long'],
        );
      }

      // Determinamos el rol para mantener la lógica actual
      // de nuestra aplicación.
      final String role;

      if (userId == 1 || userId == 2) {
        role = 'Administrador';
      } else if (userId == 3) {
        role = 'Auditor';
      } else {
        role = 'Cliente';
      }

      // Regresamos el token, ID, rol, objeto POO y datos API.
      return {
        'token': token,
        'userId': userId,
        'role': role,
        'usuario': usuario,
        'user': user,
      };
    } catch (e) {
      // Mostramos el error y lo enviamos al LoginPage.
      print('ERROR REAL: $e');
      rethrow;
    }
  }
}