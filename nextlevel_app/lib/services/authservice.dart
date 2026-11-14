import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://studious-palm-tree-x5xgvjrxq56pc9rg-8081.app.github.dev/api/auth',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  Future<bool> login(String correo, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'correo': correo,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];

        // 2. MODIFICACIÓN: Extraemos los roles sin bloquear a los clientes
        List<String> roles = List<String>.from(data['roles'] ?? []);

        // Validamos que tenga al menos un rol válido del sistema
        final bool tieneAcceso = roles.contains('ROLE_ADMIN') || 
                                 roles.contains('ROLE_CLIENTE') || 
                                 roles.contains('ROLE_USER');

        if (!tieneAcceso && roles.isEmpty) {
          throw Exception('El usuario no tiene un rol asignado.');
        }

        // Guardamos el token y los roles en memoria para usarlos en el catálogo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setStringList('user_roles', roles);

        return true;
      }
      return false;
    } on DioException catch (e) {
      // Diferenciamos si es contraseña incorrecta o bloqueo de red/CORS
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Credenciales incorrectas');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Ruta no encontrada (404). Revisa la URL del backend.');
      } else {
        throw Exception('Error de conexión o bloqueo CORS con el puerto 8081');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_roles');
  }
}