import 'package:flutter/material.dart';

// Clase abstracta que sirve como base para los diferentes tipos de usuario.
abstract class Usuario {
  // Datos comunes que todos los usuarios tienen.
  final int id;
  final String username;
  final String email;
  final String phone;

  final String firstName;
  final String lastName;

  // Datos de dirección.
  final String street;
  final int number;
  final String city;
  final String zipcode;

  // Coordenadas obtenidas de la API.
  final String latitude;
  final String longitude;

  Usuario({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.street,
    required this.number,
    required this.city,
    required this.zipcode,
    required this.latitude,
    required this.longitude,
  });

  // Métodos abstractos que cada tipo de usuario debe implementar.
  String obtenerDescripcion();

  Color obtenerColor();

  IconData obtenerIcono();

  // Método común para todos los tipos de usuario.
  String nombreCompleto() {
    return '$firstName $lastName';
  }
}


// Herencia: Administrador hereda de Usuario.
class Administrador extends Usuario {
  Administrador({
    required super.id,
    required super.username,
    required super.email,
    required super.phone,
    required super.firstName,
    required super.lastName,
    required super.street,
    required super.number,
    required super.city,
    required super.zipcode,
    required super.latitude,
    required super.longitude,
  });

  // Polimorfismo: Administrador implementa su propio comportamiento.
  @override
  String obtenerDescripcion() {
    return 'Usuario con permisos administrativos';
  }

  @override
  Color obtenerColor() {
    return Colors.deepPurple;
  }

  @override
  IconData obtenerIcono() {
    return Icons.admin_panel_settings;
  }
}


// Herencia: Auditor también hereda de Usuario.
class Auditor extends Usuario {
  Auditor({
    required super.id,
    required super.username,
    required super.email,
    required super.phone,
    required super.firstName,
    required super.lastName,
    required super.street,
    required super.number,
    required super.city,
    required super.zipcode,
    required super.latitude,
    required super.longitude,
  });

  // Polimorfismo: Auditor tiene su propia implementación.
  @override
  String obtenerDescripcion() {
    return 'Usuario con permisos de auditoría';
  }

  @override
  Color obtenerColor() {
    return Colors.blue;
  }

  @override
  IconData obtenerIcono() {
    return Icons.fact_check;
  }
}


// Herencia: Cliente hereda de Usuario.
class Cliente extends Usuario {
  Cliente({
    required super.id,
    required super.username,
    required super.email,
    required super.phone,
    required super.firstName,
    required super.lastName,
    required super.street,
    required super.number,
    required super.city,
    required super.zipcode,
    required super.latitude,
    required super.longitude,
  });

  // Polimorfismo: Cliente tiene su propia implementación.
  @override
  String obtenerDescripcion() {
    return 'Usuario con acceso como cliente';
  }

  @override
  Color obtenerColor() {
    return Colors.green;
  }

  @override
  IconData obtenerIcono() {
    return Icons.person;
  }
}