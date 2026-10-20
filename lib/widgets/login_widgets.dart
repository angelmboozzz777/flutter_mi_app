import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class LoginWidgets extends StatelessWidget {
  final TextEditingController usuarioController;
  final TextEditingController passwordController;

  final bool mostrarPassword;
  final bool cargando;

  final VoidCallback onLogin;
  final VoidCallback onMostrarPassword;

  const LoginWidgets({
    super.key,
    required this.usuarioController,
    required this.passwordController,
    required this.mostrarPassword,
    required this.cargando,
    required this.onLogin,
    required this.onMostrarPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo y nombre.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GameColors.acento,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          'GameStore',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: GameColors.texto,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      color: GameColors.texto,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Entra a tu cuenta para ver el catálogo.',
                    style: TextStyle(
                      color: GameColors.textoSecundario,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Campo de usuario.
                  TextField(
                    controller: usuarioController,
                    enabled: !cargando,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: GameColors.texto),
                    decoration: const InputDecoration(
                      labelText: 'Usuario o correo',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Campo de contraseña.
                  TextField(
                    controller: passwordController,
                    enabled: !cargando,
                    obscureText: !mostrarPassword,
                    style: const TextStyle(color: GameColors.texto),
                    onSubmitted: (_) {
                      if (!cargando) onLogin();
                    },
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 20,
                      ),

                      // Mostrar u ocultar contraseña.
                      suffixIcon: IconButton(
                        onPressed: cargando
                            ? null
                            : onMostrarPassword,
                        icon: Icon(
                          mostrarPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de inicio de sesión.
                  BotonPrincipal(
                    texto: 'Iniciar sesión',
                    cargando: cargando,
                    onPressed: onLogin,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Tu tienda de videojuegos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GameColors.textoTenue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
