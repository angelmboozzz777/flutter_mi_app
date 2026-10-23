import 'dart:convert';
import 'package:http/http.dart' as http;
 
import '../models/producto.dart';
import 'api_config.dart';
 
class ProductoService {
  // Ahora se usa GameStore API (FastAPI + MongoDB Atlas) en lugar de Fake Store API.
  static String get baseUrl => ApiConfig.baseUrl;
 
  // Convierte la respuesta a JSON respetando acentos (UTF-8).
  dynamic _decodificar(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
 
  // Si la API responde 401 o 403, el usuario no tiene permiso.
  void _validarPermiso(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception(
        'Sin permiso: inicia sesión como administrador',
      );
    }
  }
 
  // US03
  Future<List<Producto>> obtenerProductos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
    );
 
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los productos',
      );
    }
 
    final List<dynamic> data = _decodificar(response);
 
    return data
        .map(
          (item) => Producto.fromJson(item),
        )
        .toList();
  }
 
  // US04
  Future<List<String>> obtenerCategorias() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/categories'),
    );
 
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar las categorías',
      );
    }
 
    final List<dynamic> data = _decodificar(response);
 
    return data
        .map(
          (item) => item.toString(),
        )
        .toList();
  }
 
  // US04
  Future<List<Producto>> obtenerProductosPorCategoria(
    String categoria,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/games/category/${Uri.encodeComponent(categoria)}',
      ),
    );
 
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los productos de la categoría',
      );
    }
 
    final List<dynamic> data = _decodificar(response);
 
    return data
        .map(
          (item) => Producto.fromJson(item),
        )
        .toList();
  }
 
  // US05
  Future<Producto> obtenerProductoPorId(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$id'),
    );
 
    if (response.statusCode != 200) {
      throw Exception(
        'Producto no disponible',
      );
    }
 
    final Map<String, dynamic> data = _decodificar(response);
 
    return Producto.fromJson(data);
  }
 
  // US05 - Editar producto (requiere ser administrador)
  Future<Producto> actualizarProducto(
    Producto producto,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/games/${producto.id}',
      ),
      headers: ApiConfig.headers(conToken: true),
      body: jsonEncode(
        producto.toJson(),
      ),
    );
 
    _validarPermiso(response);
 
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar el producto: ${ApiConfig.detalleError(response)}',
      );
    }
 
    final Map<String, dynamic> data = _decodificar(response);
 
    return Producto.fromJson(data);
  }
 
  // US05 - Eliminar producto (requiere ser administrador)
  Future<void> eliminarProducto(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/games/$id'),
      headers: ApiConfig.headers(conToken: true),
    );
 
    _validarPermiso(response);
 
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo eliminar el producto',
      );
    }
  }
 
  // US06 - Agregar producto (requiere ser administrador)
  Future<Producto> crearProducto(
    Producto producto,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games'),
      headers: ApiConfig.headers(conToken: true),
      body: jsonEncode(
        producto.toJson(),
      ),
    );
 
    _validarPermiso(response);
 
    // La API responde 201 (Created) cuando se crea correctamente.
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'No se pudo crear el producto: ${ApiConfig.detalleError(response)}',
      );
    }
 
    final Map<String, dynamic> data = _decodificar(response);
 
    return Producto.fromJson(data);
  }
}