import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class ProfileWidgets extends StatelessWidget {
  final String role;
  final String nombreCompleto;
  final String username;
  final String userId;
  final String email;
  final String phone;
  final String calle;
  final String numero;
  final String ciudad;
  final String codigoPostal;
  final String latitud;
  final String longitud;

  final Color roleColor;
  final IconData roleIcon;
  final String descripcion;

  final VoidCallback onCerrarSesion;

  const ProfileWidgets({
    super.key,
    required this.role,
    required this.nombreCompleto,
    required this.username,
    required this.userId,
    required this.email,
    required this.phone,
    required this.calle,
    required this.numero,
    required this.ciudad,
    required this.codigoPostal,
    required this.latitud,
    required this.longitud,
    required this.roleColor,
    required this.roleIcon,
    required this.descripcion,
    required this.onCerrarSesion,
  });

  // Iniciales para el avatar, por ejemplo "Demo Gamer" -> "DG".
  String get iniciales {
    final List<String> partes = nombreCompleto
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();

    return (partes[0][0] + partes[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _encabezadoPerfil(),

                const SizedBox(height: 16),

                _seccion(
                  titulo: 'Cuenta',
                  datos: [
                    _Dato('Nombre completo', nombreCompleto),
                    _Dato('Usuario', username),
                    _Dato('ID de usuario', userId),
                  ],
                ),

                const SizedBox(height: 12),

                _seccion(
                  titulo: 'Contacto',
                  datos: [
                    _Dato('Correo electrónico', email),
                    _Dato('Teléfono', phone),
                  ],
                ),

                const SizedBox(height: 12),

                _seccion(
                  titulo: 'Dirección',
                  datos: [
                    _Dato('Calle', calle),
                    _Dato('Número', numero),
                    _Dato('Ciudad', ciudad),
                    _Dato('Código postal', codigoPostal),
                  ],
                ),

                const SizedBox(height: 12),

                _seccion(
                  titulo: 'Geolocalización',
                  datos: [
                    _Dato('Latitud', latitud),
                    _Dato('Longitud', longitud),
                  ],
                ),

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: onCerrarSesion,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GameColors.peligro,
                    side: BorderSide(
                      color: GameColors.peligro.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezadoPerfil() {
    return Panel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: roleColor.withValues(alpha: 0.18),
            child: Text(
              iniciales,
              style: TextStyle(
                color: roleColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreCompleto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GameColors.texto,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@$username',
                  style: const TextStyle(
                    color: GameColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Etiqueta(
                  texto: role,
                  color: roleColor,
                  icono: roleIcon,
                ),
                const SizedBox(height: 6),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: GameColors.textoTenue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion({
    required String titulo,
    required List<_Dato> datos,
  }) {
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              titulo,
              style: const TextStyle(
                color: GameColors.texto,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (int i = 0; i < datos.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
            _renglon(datos[i]),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _renglon(_Dato dato) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              dato.titulo,
              style: const TextStyle(
                color: GameColors.textoSecundario,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              dato.valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: GameColors.texto,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato {
  final String titulo;
  final String valor;

  const _Dato(this.titulo, this.valor);
}
