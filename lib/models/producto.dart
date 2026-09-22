class Producto {
  // Encapsulamiento
  int _id;
  String _title;
  double _price;
  String _description;
  String _category;
  String _image;

  // Constructor
  Producto({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  })  : _id = 0,
        _title = '',
        _price = 0.0,
        _description = '',
        _category = '',
        _image = '' {
    this.id = id;
    this.title = title;
    this.price = price;
    this.description = description;
    this.category = category;
    this.image = image;
  }

  // Getters
  int get id => _id;
  String get title => _title;
  double get price => _price;
  String get description => _description;
  String get category => _category;
  String get image => _image;

  // Setters con validaciones
  set id(int value) {
    if (value <= 0) {
      throw ArgumentError('El ID debe ser mayor que 0');
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

  // Convierte JSON en un objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.parse(json['id'].toString()),
      title: json['title'].toString(),
      price: double.parse(json['price'].toString()),
      description: json['description'].toString(),
      category: json['category'].toString(),
      image: json['image'].toString(),
    );
  }

  // Convierte el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'price': _price,
      'description': _description,
      'category': _category,
      'image': _image,
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