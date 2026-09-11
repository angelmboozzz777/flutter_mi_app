import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../storage/secure_storage.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  // Datos que seguimos utilizando de la sesión.
  final String role;
  final int userId;

  // Objeto Usuario recibido desde AuthService.
  // Puede ser Administrador, Auditor o Cliente.
  final Usuario usuario;

  // Datos originales obtenidos de la API.
  final Map<String, dynamic> user;

  const HomePage({
    super.key,
    required this.role,
    required this.userId,
    required this.usuario,
    required this.user,
  });

  // ==========================================================
  // CERRAR SESIÓN
  // ==========================================================

  Future<void> cerrarSesion(BuildContext context) async {
    final storageService = SecureStorageService();

    // Eliminamos la información de sesión almacenada.
    await storageService.clearSession();

    if (!context.mounted) return;

    // Eliminamos las pantallas anteriores del historial.
    // Así el usuario no puede regresar al perfil después
    // de cerrar sesión.
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
    // ========================================================
    // POLIMORFISMO
    // ========================================================
    // El objeto "usuario" puede ser Administrador, Auditor
    // o Cliente. Cada clase tiene su propia implementación
    // de estos métodos.
    final Color roleColor = usuario.obtenerColor();
    final IconData roleIcon = usuario.obtenerIcono();
    final String descripcion = usuario.obtenerDescripcion();

    // ========================================================
    // DATOS DEL USUARIO
    // ========================================================

    final String username =
        usuario.username;

    final String email =
        usuario.email;

    final String phone =
        usuario.phone;

    final String firstName =
        usuario.firstName;

    final String lastName =
        usuario.lastName;

    final String street =
        usuario.street;

    final String number =
        usuario.number.toString();

    final String city =
        usuario.city;

    final String zipcode =
        usuario.zipcode;

    final String latitude =
        usuario.latitude;

    final String longitude =
        usuario.longitude;

    return PopScope(
      // Impide regresar desde la pantalla protegida.
      canPop: false,

      child: Scaffold(
        backgroundColor:
            roleColor.withValues(alpha: 0.08),

        // ======================================================
        // BARRA SUPERIOR
        // ======================================================

        appBar: AppBar(
          backgroundColor: roleColor,
          foregroundColor: Colors.white,
          title: const Text('Mi perfil'),
          centerTitle: true,

          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () => cerrarSesion(context),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),

        // ======================================================
        // CONTENIDO
        // ======================================================

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // ==================================================
              // PERFIL
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    // El icono viene del objeto polimórfico.
                    Container(
                      width: 110,
                      height: 110,

                      decoration: BoxDecoration(
                        color: roleColor,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        roleIcon,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Utilizamos el método común de Usuario.
                    Text(
                      usuario.nombreCompleto(),
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '@$username',

                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Mostramos el rol correspondiente.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Text(
                        role,

                        style: TextStyle(
                          color: roleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Descripción propia de cada tipo de usuario.
                    Text(
                      descripcion,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFORMACIÓN PERSONAL
              // ==================================================

              _seccion(
                titulo: 'Información personal',
                icono: Icons.person_outline,
                color: roleColor,

                contenido: Column(
                  children: [
                    _dato(
                      icono: Icons.badge_outlined,
                      titulo: 'ID de usuario',
                      valor: userId.toString(),
                    ),

                    _dato(
                      icono: Icons.person_outline,
                      titulo: 'Nombre',
                      valor: firstName,
                    ),

                    _dato(
                      icono: Icons.person_outline,
                      titulo: 'Apellido',
                      valor: lastName,
                    ),

                    _dato(
                      icono: Icons.account_circle_outlined,
                      titulo: 'Usuario',
                      valor: username,
                    ),

                    _dato(
                      icono: Icons.email_outlined,
                      titulo: 'Correo electrónico',
                      valor: email,
                    ),

                    _dato(
                      icono: Icons.phone_outlined,
                      titulo: 'Teléfono',
                      valor: phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // DIRECCIÓN
              // ==================================================

              _seccion(
                titulo: 'Dirección',
                icono: Icons.home_outlined,
                color: roleColor,

                contenido: Column(
                  children: [
                    _dato(
                      icono: Icons.signpost_outlined,
                      titulo: 'Calle',
                      valor: street,
                    ),

                    _dato(
                      icono: Icons.numbers,
                      titulo: 'Número',
                      valor: number,
                    ),

                    _dato(
                      icono: Icons.location_city_outlined,
                      titulo: 'Ciudad',
                      valor: city,
                    ),

                    _dato(
                      icono: Icons.markunread_mailbox_outlined,
                      titulo: 'Código postal',
                      valor: zipcode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // GEOLOCALIZACIÓN
              // ==================================================

              _seccion(
                titulo: 'Geolocalización',
                icono: Icons.location_on_outlined,
                color: roleColor,

                contenido: Column(
                  children: [
                    _dato(
                      icono: Icons.north_outlined,
                      titulo: 'Latitud',
                      valor: latitude,
                    ),

                    _dato(
                      icono: Icons.east_outlined,
                      titulo: 'Longitud',
                      valor: longitude,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Coordenadas obtenidas desde Fake Store API',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // CERRAR SESIÓN
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () => cerrarSesion(context),

                  icon: const Icon(Icons.logout),

                  label: const Text(
                    'Cerrar sesión',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SECCIÓN REUTILIZABLE
  // ==========================================================

  Widget _seccion({
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget contenido,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  icono,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                titulo,

                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          contenido,
        ],
      ),
    );
  }

  // ==========================================================
  // DATO REUTILIZABLE
  // ==========================================================

  Widget _dato({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            icono,
            color: usuario.obtenerColor(),
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  titulo,

                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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