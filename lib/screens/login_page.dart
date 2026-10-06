import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/auth_service.dart';
import '../storage/secure_storage.dart';
import '../models/usuario.dart';
import '../widgets/login_widgets.dart';
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
  final SecureStorageService storageService =
      SecureStorageService();

  @override
  void dispose() {
    // Liberamos los controladores.
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginWidgets(
      usuarioController: usuarioController,
      passwordController: passwordController,
      mostrarPassword: mostrarPassword,
      cargando: cargando,
      onLogin: iniciarSesion,
      onMostrarPassword: cambiarVisibilidadPassword,
    );
  }

  // Cambia la visibilidad de la contraseña.
  void cambiarVisibilidadPassword() {
    setState(() {
      mostrarPassword = !mostrarPassword;
    });
  }

  // ==========================================================
  // INICIO DE SESIÓN
  // ==========================================================

  Future<void> iniciarSesion() async {
    // Obtenemos los datos escritos en los campos.
    final usuarioIngresado =
        usuarioController.text.trim();

    final password =
        passwordController.text.trim();

    // Validamos que los campos no estén vacíos.
    if (usuarioIngresado.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa todos los campos',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // Activamos el indicador de carga.
    setState(() {
      cargando = true;
    });

    // ==========================================================
    // COMPROBACIÓN DE INTERNET - US01
    // ==========================================================

    final conexion =
        await Connectivity().checkConnectivity();

    if (conexion.contains(ConnectivityResult.none)) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay conexión a Internet',
          ),
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

      // Credenciales rechazadas por la API.
      if (resultado == null) {
        setState(() {
          cargando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Usuario o contraseña inválidos',
            ),
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
      final Usuario usuario =
          resultado['usuario'] as Usuario;

      // Conservamos los datos originales de la API.
      final user =
          resultado['user'] as Map<String, dynamic>;

      // ==========================================================
      // GUARDADO DE LA SESIÓN
      // ==========================================================

      await storageService.saveSession(
        token: token,
        role: role,
        userId: userId,
      );

      if (!mounted) return;

      // Entramos a la pantalla principal.
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

      // Detectamos errores de conexión.
      final error = e.toString();

      final sinInternet =
          e is SocketException ||
          error.contains('Failed host lookup') ||
          error.contains('Connection failed') ||
          error.contains('Network is unreachable') ||
          error.contains('No Internet');

      // Mostramos el mensaje correspondiente.
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