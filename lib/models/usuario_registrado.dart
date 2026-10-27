// ==========================================================
// US11 - Usuario tal como lo devuelve GET /users
//
// El JSON trae objetos anidados (name, address y, en algunas
// APIs, address.geolocation). Cada parte se lee con valores por
// defecto, así un campo nulo o faltante nunca tumba la app.
// ==========================================================

// Convierte cualquier valor a texto sin fallar con null.
String _texto(dynamic valor) => (valor ?? '').toString().trim();

// Lee un objeto anidado; si no es un Map, regresa uno vacío.
Map<String, dynamic> _mapa(dynamic valor) =>
    valor is Map ? Map<String, dynamic>.from(valor) : <String, dynamic>{};

class NombreUsuario {
  final String nombre;
  final String apellido;

  const NombreUsuario({required this.nombre, required this.apellido});

  factory NombreUsuario.fromJson(dynamic json) {
    final datos = _mapa(json);
    return NombreUsuario(
      nombre: _texto(datos['firstname']),
      apellido: _texto(datos['lastname']),
    );
  }

  String get completo => '$nombre $apellido'.trim();
}

class Geolocalizacion {
  final double? latitud;
  final double? longitud;

  const Geolocalizacion({this.latitud, this.longitud});

  factory Geolocalizacion.fromJson(dynamic json) {
    final datos = _mapa(json);
    return Geolocalizacion(
      latitud: double.tryParse(_texto(datos['lat'])),
      longitud: double.tryParse(_texto(datos['long'])),
    );
  }

  bool get tieneDatos => latitud != null && longitud != null;
}

class DireccionUsuario {
  final String calle;
  final String numero;
  final String ciudad;
  final String codigoPostal;
  final Geolocalizacion geolocalizacion;

  const DireccionUsuario({
    required this.calle,
    required this.numero,
    required this.ciudad,
    required this.codigoPostal,
    required this.geolocalizacion,
  });

  factory DireccionUsuario.fromJson(dynamic json) {
    final datos = _mapa(json);
    return DireccionUsuario(
      calle: _texto(datos['street']),
      numero: _texto(datos['number']),
      ciudad: _texto(datos['city']),
      codigoPostal: _texto(datos['zipcode']),
      geolocalizacion: Geolocalizacion.fromJson(datos['geolocation']),
    );
  }

  bool get estaVacia =>
      calle.isEmpty && numero.isEmpty && ciudad.isEmpty && codigoPostal.isEmpty;

  // "Av. Universidad #100, Querétaro, C.P. 76000" (solo lo que exista).
  String get completa {
    final partes = <String>[
      [calle, if (numero.isNotEmpty) '#$numero'].join(' ').trim(),
      ciudad,
      if (codigoPostal.isNotEmpty) 'C.P. $codigoPostal',
    ].where((parte) => parte.isNotEmpty);
    return partes.join(', ');
  }
}

class UsuarioRegistrado {
  final int id;
  final String usuario;
  final String correo;
  final String telefono;
  final String rol; // admin | auditor | user
  final NombreUsuario nombre;
  final DireccionUsuario direccion;

  const UsuarioRegistrado({
    required this.id,
    required this.usuario,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.nombre,
    required this.direccion,
  });

  factory UsuarioRegistrado.fromJson(Map<String, dynamic> json) {
    return UsuarioRegistrado(
      id: int.tryParse(_texto(json['id'])) ?? 0,
      usuario: _texto(json['username']),
      correo: _texto(json['email']),
      telefono: _texto(json['phone']),
      rol: _texto(json['role']).isEmpty ? 'user' : _texto(json['role']),
      nombre: NombreUsuario.fromJson(json['name']),
      direccion: DireccionUsuario.fromJson(json['address']),
    );
  }

  // Si no tiene nombre registrado se muestra su usuario.
  String get nombreVisible =>
      nombre.completo.isNotEmpty ? nombre.completo : usuario;

  String get rolVisible {
    switch (rol) {
      case 'admin':
        return 'Administrador';
      case 'auditor':
        return 'Auditor';
      default:
        return 'Cliente';
    }
  }

  // Iniciales para el avatar: "Angel Ramirez" -> "AR".
  String get iniciales {
    final palabras = nombreVisible
        .split(' ')
        .where((palabra) => palabra.isNotEmpty)
        .toList();
    if (palabras.isEmpty) return '?';
    if (palabras.length == 1) return palabras.first[0].toUpperCase();
    return (palabras[0][0] + palabras[1][0]).toUpperCase();
  }

  // Para el buscador: nombre, usuario o correo.
  bool coincideCon(String texto) {
    final buscado = texto.toLowerCase();
    return nombreVisible.toLowerCase().contains(buscado) ||
        usuario.toLowerCase().contains(buscado) ||
        correo.toLowerCase().contains(buscado);
  }
}
