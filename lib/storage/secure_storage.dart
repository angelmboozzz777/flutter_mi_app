import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  // ==========================================================
  // GUARDAR SESIÓN
  // ==========================================================

  Future<void> saveSession({
    required String token,
    required String role,
    required int userId,
  }) async {
    await _storage.write(
      key: 'token',
      value: token,
    );

    await _storage.write(
      key: 'role',
      value: role,
    );

    await _storage.write(
      key: 'userId',
      value: userId.toString(),
    );
  }

  // ==========================================================
  // OBTENER ROL
  // ==========================================================

  Future<String?> getRole() async {
    return await _storage.read(
      key: 'role',
    );
  }

  // ==========================================================
  // OBTENER ID
  // ==========================================================

  Future<int?> getUserId() async {
    final value = await _storage.read(
      key: 'userId',
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  // ==========================================================
  // OBTENER TOKEN
  // ==========================================================

  Future<String?> getToken() async {
    return await _storage.read(
      key: 'token',
    );
  }

  // ==========================================================
  // CERRAR SESIÓN
  // ==========================================================

  Future<void> clearSession() async {
    await _storage.delete(
      key: 'token',
    );

    await _storage.delete(
      key: 'role',
    );

    await _storage.delete(
      key: 'userId',
    );
  }
}