class Producto {
  // Encapsulamiento
  int _id;
  String _title;
  double _price;
  String _description;
  String _category;
  String _image;
  String _platform;
  int _stock;

  // Constructor
  // El id puede ser 0 cuando el producto todavía no existe en la API
  // (por ejemplo, al crearlo). La API le asigna su id real.
  Producto({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    String platform = 'PC',
    int stock = 0,
  })  : _id = 0,
        _title = '',
        _price = 0.0,
        _description = '',
        _category = '',
        _image = '',
        _platform = 'PC',
        _stock = 0 {
    this.id = id;
    this.title = title;
    this.price = price;
    this.description = description;
    this.category = category;
    this.image = image;
    this.platform = platform;
    this.stock = stock;
  }

  // Getters
  int get id => _id;
  String get title => _title;
  double get price => _price;
  String get description => _description;
  String get category => _category;
  String get image => _image;
  String get platform => _platform;
  int get stock => _stock;

  // Setters con validaciones
  set id(int value) {
    if (value < 0) {
      throw ArgumentError('El ID no puede ser negativo');
    }
    _id = value;
  }

  set title(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    _title = value.trim();
  }

  set price(double value) {
    if (value < 0) {
      throw ArgumentError('El precio no puede ser negativo');
    }
    _price = value;
  }

  set description(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('La descripción no puede estar vacía');
    }
    _description = value.trim();
  }

  set category(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('La categoría no puede estar vacía');
    }
    _category = value.trim();
  }

  set image(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('La imagen no puede estar vacía');
    }
    _image = value.trim();
  }

  set platform(String value) {
    _platform = value.trim().isEmpty ? 'PC' : value.trim();
  }

  set stock(int value) {
    if (value < 0) {
      throw ArgumentError('El stock no puede ser negativo');
    }
    _stock = value;
  }

  // Convierte JSON en un objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.parse(json['id'].toString()),
      title: json['title'].toString(),
      price: double.parse(json['price'].toString()),
      description: json['description'].toString(),
      category: json['category'].toString(),
      image: json['image'].toString(),
      platform: (json['platform'] ?? 'PC').toString(),
      stock: int.tryParse((json['stock'] ?? 0).toString()) ?? 0,
    );
  }

  // Convierte el objeto a JSON.
  // El id no se manda: la API lo toma de la URL o lo genera al crear.
  Map<String, dynamic> toJson() {
    return {
      'title': _title,
      'price': _price,
      'description': _description,
      'category': _category,
      'image': _image,
      'platform': _platform,
      'stock': _stock,
    };
  }

  String obtenerInformacion() {
    return '$_title - \$$_price';
  }

  @override
  String toString() {
    return 'Producto(id: $_id, title: $_title, price: $_price)';
  }
}
