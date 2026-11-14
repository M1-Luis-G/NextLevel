class Producto {
  final String? id;
  final String nombre;
  final double precio;
  final String categoria;
  final int stock;
  final String descripcion;
  final String? imagenUrl;

  static const String _baseBackendUrl =
      'https://studious-palm-tree-x5xgvjrxq56pc9rg-8081.app.github.dev';

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.stock,
    required this.descripcion,
    this.imagenUrl,
  });

  static String? _normalizarUrlImagen(dynamic valorCrudo) {
    if (valorCrudo == null) return null;
    final raw = valorCrudo.toString().trim();
    if (raw.isEmpty) return null;

    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:image')) {
      return raw;
    }

    final nombreArchivo = raw.split('/').last;
    return '$_baseBackendUrl/api/productos/imagen/$nombreArchivo';
  }

  static String _prepararImagenParaGuardar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return '/images/prod1.png';
    }
    final limpio = valor.trim();
    if (limpio.startsWith('http://') ||
        limpio.startsWith('https://') ||
        limpio.startsWith('/images/')) {
      return limpio;
    }
    if (limpio.startsWith('images/')) {
      return '/$limpio';
    }
    return '/images/$limpio';
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    final rawImg =
        json['imagen'] ??
        json['imagenUrl'] ??
        json['urlImagen'] ??
        json['image'] ??
        json['foto'];

    return Producto(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      nombre: (json['nombre'] ?? json['name'] ?? 'Sin nombre').toString(),
      precio:
          double.tryParse((json['precio'] ?? json['price'] ?? 0).toString()) ??
          0.0,
      categoria: (json['categoria'] ?? json['category'] ?? 'General')
          .toString(),
      stock:
          int.tryParse((json['stock'] ?? json['cantidad'] ?? 0).toString()) ??
          0,
      descripcion: (json['descripcion'] ?? json['description'] ?? '')
          .toString(),
      imagenUrl: _normalizarUrlImagen(rawImg),
    );
  }

  Map<String, dynamic> toJson() {
    final rutaImagen = _prepararImagenParaGuardar(imagenUrl);
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'stock': stock,
      'descripcion': descripcion,
      'imagen': rutaImagen,
    };
  }
}
