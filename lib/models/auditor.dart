import 'package:flutter/material.dart';
import 'usuario.dart';

// Clase hija que hereda de Usuario.
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

  // Polimorfismo: implementación propia del auditor.
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