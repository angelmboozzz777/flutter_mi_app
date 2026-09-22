import 'package:flutter/material.dart';
import 'usuario.dart';

// Clase hija que hereda de Usuario.
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

  // Polimorfismo: implementación propia del cliente.
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