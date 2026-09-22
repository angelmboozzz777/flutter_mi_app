import 'package:flutter/material.dart';
import 'usuario.dart';

// Clase hija que hereda de Usuario.
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

  // Polimorfismo: implementación propia del administrador.
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