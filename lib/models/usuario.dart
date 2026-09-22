import 'package:flutter/material.dart';

abstract class Usuario {
  // ======================================================
  // ATRIBUTOS PRIVADOS
  // ======================================================

  int _id;
  String _username;
  String _email;
  String _phone;

  String _firstName;
  String _lastName;

  String _street;
  int _number;
  String _city;
  String _zipcode;

  double _latitude;
  double _longitude;

  // ======================================================
  // CONSTRUCTOR
  // ======================================================

  Usuario({
    required int id,
    required String username,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String street,
    required int number,
    required String city,
    required String zipcode,
    required double latitude,
    required double longitude,
  })  : _id = 0,
        _username = '',
        _email = '',
        _phone = '',
        _firstName = '',
        _lastName = '',
        _street = '',
        _number = 0,
        _city = '',
        _zipcode = '',
        _latitude = 0,
        _longitude = 0 {
    // Los datos pasan por los setters para validarse.
    this.id = id;
    this.username = username;
    this.email = email;
    this.phone = phone;
    this.firstName = firstName;
    this.lastName = lastName;
    this.street = street;
    this.number = number;
    this.city = city;
    this.zipcode = zipcode;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  // ======================================================
  // GETTERS
  // Permiten consultar los datos y darles formato de salida.
  // ======================================================

  int get id {
    return _id;
  }

  String get username {
    return _username;
  }

  String get email {
    return _email.toLowerCase();
  }

  String get phone {
    return 'Teléfono: $_phone';
  }

  String get firstName {
    return _firstName[0].toUpperCase() + _firstName.substring(1);
  }

  String get lastName {
    return _lastName[0].toUpperCase() + _lastName.substring(1);
  }

  String get street {
    return _street;
  }

  int get number {
    return _number;
  }

  String get city {
    return _city;
  }

  String get zipcode {
    return _zipcode;
  }

  double get latitude {
    return _latitude;
  }

  double get longitude {
    return _longitude;
  }

  // Getter con formato para mostrar el nombre completo.
  String get nombreCompleto {
    return '$firstName $lastName';
  }

  // Getter con formato para mostrar la dirección.
  String get direccionCompleta {
    return '$_street #$_number, $_city, C.P. $_zipcode';
  }

  // Getter con formato para mostrar las coordenadas.
  String get coordenadas {
    return 'Latitud: $_latitude, Longitud: $_longitude';
  }

  // ======================================================
  // SETTERS
  // Permiten modificar los datos aplicando validaciones.
  // ======================================================

  set id(int value) {
    if (value <= 0) {
      throw ArgumentError('El ID debe ser mayor que cero');
    }

    _id = value;
  }

  set username(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'El nombre de usuario no puede estar vacío',
      );
    }

    _username = value.trim();
  }

  set email(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'El correo no puede estar vacío',
      );
    }

    if (!value.contains('@') || !value.contains('.')) {
      throw ArgumentError(
        'El correo no tiene un formato válido',
      );
    }

    _email = value.trim().toLowerCase();
  }

  set phone(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'El teléfono no puede estar vacío',
      );
    }

    _phone = value.trim();
  }

  set firstName(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'El nombre no puede estar vacío',
      );
    }

    _firstName = value.trim();
  }

  set lastName(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'El apellido no puede estar vacío',
      );
    }

    _lastName = value.trim();
  }

  set street(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'La calle no puede estar vacía',
      );
    }

    _street = value.trim();
  }

  set number(int value) {
    if (value < 0) {
      throw ArgumentError(
        'El número de casa no puede ser negativo',
      );
    }

    _number = value;
  }

  set city(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'La ciudad no puede estar vacía',
      );
    }

    _city = value.trim();
  }

  set zipcode(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'El código postal no puede estar vacío',
      );
    }

    _zipcode = value.trim();
  }

  set latitude(double value) {
    if (value < -90 || value > 90) {
      throw ArgumentError(
        'La latitud debe estar entre -90 y 90',
      );
    }

    _latitude = value;
  }

  set longitude(double value) {
    if (value < -180 || value > 180) {
      throw ArgumentError(
        'La longitud debe estar entre -180 y 180',
      );
    }

    _longitude = value;
  }

  // ======================================================
  // MÉTODOS ABSTRACTOS
  // Cada clase hija debe implementarlos.
  // ======================================================

  String obtenerDescripcion();

  Color obtenerColor();

  IconData obtenerIcono();
}