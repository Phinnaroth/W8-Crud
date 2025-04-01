import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dto/pancake_dto.dart';
import '../model/pancake.dart';
import 'pancake_repository.dart';

class FirebasePancakeRepository extends PancakeRepository {
  static const String baseUrl = 'https://w8-restapi-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String pancakesCollection = "pancakes";
  static const String allPancakesUrl = '$baseUrl/$pancakesCollection.json';

  @override
  Future<Pancake> addPancake({required String color, required double price}) async {
    Uri uri = Uri.parse(allPancakesUrl);

    final newPancakeData = {'color': color, 'price': price};
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newPancakeData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add pancake');
    }

    // Firebase returns the new ID in 'name'
    final newId = json.decode(response.body)['name'];

    // Return created pancake
    return Pancake(id: newId, color: color, price: price);
  }

  @override
  Future<void> deletePancake(String id) async {
    Uri uri = Uri.parse('$baseUrl/$pancakesCollection/$id.json');

    final http.Response response = await http.delete(uri);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete pancake');
    }
  }

  @override
  Future<List<Pancake>> getPancakes() async {
    Uri uri = Uri.parse(allPancakesUrl);
    final http.Response response = await http.get(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load pancakes');
    }

    // Return all pancakes
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];
    return data.entries
        .map((entry) => PancakeDto.fromJson(entry.key, entry.value))
        .toList();
  }

  @override
  Future<void> updatePancake({required String id, required String color, required double price}) async {
    Uri uri = Uri.parse('$baseUrl/$pancakesCollection/$id.json');
    final updateData = {'color': color, 'price': price};

    // Update the pancake data
    final http.Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to update pancake');
    }
  }
}
