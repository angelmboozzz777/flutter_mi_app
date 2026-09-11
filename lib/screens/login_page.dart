import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/auth_service.dart';
import '../storage/secure_storage.dart';
import '../models/usuario.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para obtener el usuario y la contraseña.
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  // Estados de la pantalla.
  bool mostrarPassword = false;
  bool cargando = false;

  // Servicios para consumir la API y guardar la sesión.
  final AuthService authService = AuthService();
  final SecureStorageService storageService = SecureStorageService();

  @override
  void dispose() {
    // Liberamos los controladores cuando se elimina la pantalla.
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Icono principal de la pantalla de acceso.
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // Campo para escribir el nombre de usuario.
                TextField(
                  controller: usuarioController,
                  enabled: !cargando,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    hintText: 'Ingresa tu usuario',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Campo para escribir la contraseña.
                TextField(
                  controller: passwordController,
                  enabled: !cargando,
                  obscureText: !mostrarPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),

                    // Botón para mostrar u ocultar la contraseña.
                    suffixIcon: IconButton(
                      onPressed: cargando
                          ? null
                          : () {
                              setState(() {
                                mostrarPassword = !mostrarPassword;
                              });
                            },
                      icon: Icon(
                        mostrarPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Botón que inicia el proceso de autenticación.
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: cargando ? null : iniciarSesion,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          Colors.deepPurple.shade200,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: cargando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Sistema de acceso',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INICIO DE SESIÓN
  // ==========================================================

  Future<void> iniciarSesion() async {
    // Obtenemos los datos escritos en los campos.
    final usuarioIngresado = usuarioController.text.trim();
    final password = passwordController.text.trim();

    // Validamos que los campos no estén vacíos.
    if (usuarioIngresado.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // Activamos el indicador de carga y deshabilitamos los campos.
    setState(() {
      cargando = true;
    });

    // ==========================================================
    // COMPROBACIÓN DE INTERNET - US01
    // ==========================================================

    // Revisamos la conexión antes de intentar consumir la API.
    final conexion = await Connectivity().checkConnectivity();

    if (conexion.contains(ConnectivityResult.none)) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay conexión a Internet'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ==========================================================
    // CONSUMO DE LA API
    // ==========================================================

    try {
      // AuthService realiza el login con Fake Store API.
      final resultado = await authService.login(
        usuarioIngresado,
        password,
      );

      if (!mounted) return;

      // US01: mostramos el mensaje solicitado si las credenciales
      // son rechazadas por la API.
      if (resultado == null) {
        setState(() {
          cargando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña inválidos'),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // Recuperamos los datos obtenidos durante el login.
      final token = resultado['token'] as String;
      final userId = resultado['userId'] as int;
      final role = resultado['role'] as String;

      // Recuperamos el objeto creado mediante polimorfismo.
      final Usuario usuario = resultado['usuario'] as Usuario;

      // Conservamos los datos originales de la API.
      final user = resultado['user'] as Map<String, dynamic>;

      // ==========================================================
      // GUARDADO DE LA SESIÓN
      // ==========================================================

      // Guardamos el token, rol e ID en almacenamiento seguro.
      await storageService.saveSession(
        token: token,
        role: role,
        userId: userId,
      );

      if (!mounted) return;

      // Entramos a la pantalla principal y reemplazamos el Login.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            role: role,
            userId: userId,
            user: user,
            usuario: usuario,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      // Algunos dispositivos tienen Wi-Fi conectado,
      // pero no cuentan con acceso real a Internet.
      final error = e.toString();

      final sinInternet =
          e is SocketException ||
          error.contains('Failed host lookup') ||
          error.contains('Connection failed') ||
          error.contains('Network is unreachable') ||
          error.contains('No Internet');

      // Mostramos un mensaje sencillo cuando el problema
      // corresponde a una falta de conexión.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sinInternet
                ? 'No hay conexión a Internet'
                : 'Error: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}