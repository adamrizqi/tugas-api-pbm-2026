import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produk_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  Future<List<Product>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);
      List<dynamic> dataList = [];
      
      if (body['data'] != null && body['data']['products'] != null) {
        dataList = body['data']['products'];
      } else if (body['products'] != null) {
        dataList = body['products'];
      }
      
      return dataList.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error fetch data');
    }
  }

  Future<bool> saveProduct(String token, String name, int price, String desc) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': desc,
      }),
    );
    
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> submitAssignment(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteProduct(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    return response.statusCode == 200 || response.statusCode == 204;
  }
}