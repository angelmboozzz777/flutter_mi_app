import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/producto.dart';

class ProductoService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // US03
  Future<List<Producto>> obtenerProductos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los productos',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map(
          (item) => Producto.fromJson(item),
        )
        .toList();
  }

  // US04
  Future<List<String>> obtenerCategorias() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/categories'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar las categorías',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

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
        '$baseUrl/products/category/${Uri.encodeComponent(categoria)}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los productos de la categoría',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

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
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Producto no disponible',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    return Producto.fromJson(data);
  }

  // US05 - Editar producto
  Future<Producto> actualizarProducto(
    Producto producto,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/products/${producto.id}',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        producto.toJson(),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar el producto',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    return Producto.fromJson(data);
  }

  // US05 - Eliminar producto
  Future<void> eliminarProducto(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo eliminar el producto',
      );
    }
  }
}