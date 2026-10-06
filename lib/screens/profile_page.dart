import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../storage/secure_storage.dart';
import '../widgets/profile_widgets.dart';
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
    // Información del rol.
    final Color roleColor = usuario.obtenerColor();
    final IconData roleIcon = usuario.obtenerIcono();
    final String descripcion =
        usuario.obtenerDescripcion();

    // Datos del usuario.
    final String username =
        user['username']?.toString() ??
            'No disponible';

    final String email =
        user['email']?.toString() ??
            'No disponible';

    final String phone =
        user['phone']?.toString() ??
            'No disponible';

    // Dirección.
    final Map<String, dynamic> address =
        user['address'] is Map
            ? Map<String, dynamic>.from(
                user['address'],
              )
            : {};

    // Geolocalización.
    final Map<String, dynamic> geolocation =
        address['geolocation'] is Map
            ? Map<String, dynamic>.from(
                address['geolocation'],
              )
            : {};

    return ProfileWidgets(
      role: role,
      nombreCompleto: usuario.nombreCompleto,
      username: username,
      userId: userId.toString(),
      email: email,
      phone: phone,
      calle: address['street']?.toString() ??
          'No disponible',
      numero: address['number']?.toString() ??
          'No disponible',
      ciudad: address['city']?.toString() ??
          'No disponible',
      codigoPostal:
          address['zipcode']?.toString() ??
              'No disponible',
      latitud:
          geolocation['lat']?.toString() ??
              'No disponible',
      longitud:
          geolocation['long']?.toString() ??
              'No disponible',
      roleColor: roleColor,
      roleIcon: roleIcon,
      descripcion: descripcion,
      onCerrarSesion: () {
        cerrarSesion(context);
      },
    );
  }
}