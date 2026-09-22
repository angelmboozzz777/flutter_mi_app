import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../storage/secure_storage.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final String role;
  final int userId;
  final Usuario usuario;
  final Map<String, dynamic> user;

  const ProfilePage({
    super.key,
    required this.role,
    required this.userId,
    required this.usuario,
    required this.user,
  });

  Future<void> cerrarSesion(BuildContext context) async {
    final storageService = SecureStorageService();

    await storageService.clearSession();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color roleColor = usuario.obtenerColor();
    final IconData roleIcon = usuario.obtenerIcono();
    final String descripcion = usuario.obtenerDescripcion();

    final String username =
        user['username']?.toString() ?? 'No disponible';

    final String email =
        user['email']?.toString() ?? 'No disponible';

    final String phone =
        user['phone']?.toString() ?? 'No disponible';

    final Map<String, dynamic> address =
        user['address'] is Map
            ? Map<String, dynamic>.from(user['address'])
            : {};

    final Map<String, dynamic> geolocation =
        address['geolocation'] is Map
            ? Map<String, dynamic>.from(
                address['geolocation'],
              )
            : {};

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
            _encabezadoPerfil(
              roleColor,
              roleIcon,
              descripcion,
              username,
            ),

            const SizedBox(height: 18),

            _seccion(
              titulo: 'Información personal',
              icono: Icons.person_outline,
              children: [
                _dato(
                  'Nombre completo',
                  usuario.nombreCompleto,
                  Icons.badge_outlined,
                ),

                _dato(
                  'Usuario',
                  username,
                  Icons.account_circle_outlined,
                ),

                _dato(
                  'ID de usuario',
                  userId.toString(),
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
                  address['street']?.toString() ??
                      'No disponible',
                  Icons.home_outlined,
                ),

                _dato(
                  'Número',
                  address['number']?.toString() ??
                      'No disponible',
                  Icons.pin_outlined,
                ),

                _dato(
                  'Ciudad',
                  address['city']?.toString() ??
                      'No disponible',
                  Icons.location_city_outlined,
                ),

                _dato(
                  'Código postal',
                  address['zipcode']?.toString() ??
                      'No disponible',
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
                  geolocation['lat']?.toString() ??
                      'No disponible',
                  Icons.north_outlined,
                ),

                _dato(
                  'Longitud',
                  geolocation['long']?.toString() ??
                      'No disponible',
                  Icons.east_outlined,
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  cerrarSesion(context);
                },
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

  Widget _encabezadoPerfil(
    Color roleColor,
    IconData roleIcon,
    String descripcion,
    String username,
  ) {
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
            usuario.nombreCompleto,
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