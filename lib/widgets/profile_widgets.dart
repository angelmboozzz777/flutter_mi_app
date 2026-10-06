import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _encabezadoPerfil(),

            const SizedBox(height: 18),

            _seccion(
              titulo: 'Información personal',
              icono: Icons.person_outline,
              children: [
                _dato(
                  'Nombre completo',
                  nombreCompleto,
                  Icons.badge_outlined,
                ),
                _dato(
                  'Usuario',
                  username,
                  Icons.account_circle_outlined,
                ),
                _dato(
                  'ID de usuario',
                  userId,
                  Icons.numbers_outlined,
                ),
              ],
            ),

            const SizedBox(height: 15),

            _seccion(
              titulo: 'Información de contacto',
              icono: Icons.contact_mail_outlined,
              children: [
                _dato(
                  'Correo electrónico',
                  email,
                  Icons.email_outlined,
                ),
                _dato(
                  'Teléfono',
                  phone,
                  Icons.phone_outlined,
                ),
              ],
            ),

            const SizedBox(height: 15),

            _seccion(
              titulo: 'Dirección',
              icono: Icons.location_on_outlined,
              children: [
                _dato(
                  'Calle',
                  calle,
                  Icons.home_outlined,
                ),
                _dato(
                  'Número',
                  numero,
                  Icons.pin_outlined,
                ),
                _dato(
                  'Ciudad',
                  ciudad,
                  Icons.location_city_outlined,
                ),
                _dato(
                  'Código postal',
                  codigoPostal,
                  Icons.markunread_mailbox_outlined,
                ),
              ],
            ),

            const SizedBox(height: 15),

            _seccion(
              titulo: 'Geolocalización',
              icono: Icons.map_outlined,
              children: [
                _dato(
                  'Latitud',
                  latitud,
                  Icons.north_outlined,
                ),
                _dato(
                  'Longitud',
                  longitud,
                  Icons.east_outlined,
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCerrarSesion,
                icon: const Icon(
                  Icons.logout,
                ),
                label: const Text(
                  'Cerrar sesión',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _encabezadoPerfil() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            roleColor,
            roleColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: roleColor.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              roleIcon,
              color: Colors.white,
              size: 45,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '@$username',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icono,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  Widget _dato(
    String titulo,
    String valor,
    IconData icono,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 20,
            color: Colors.grey,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}