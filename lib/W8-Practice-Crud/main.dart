import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'async_value.dart';

// REPOS
abstract class PancakeRepository {
  Future<Pancake> addPancake({required String color, required double price});
  Future<List<Pancake>> getPancakes();
  Future<void> updatePancake({required String id, required String color, required double price});
  Future<void> deletePancake(String id) async {}
}

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

// class MockPancakeRepository extends PancakeRepository {
//   final List<Pancake> pancakes = [];

//   @override
//   Future<Pancake> addPancake({required String color, required double price}) {
//     return Future.delayed(Duration(seconds: 1), () {
//       Pancake newPancake = Pancake(id: "0", color: color, price: price);
//       pancakes.add(newPancake);
//       return newPancake;
//     });
//   }

//   @override
//   Future<List<Pancake>> getPancakes() {
//     return Future.delayed(Duration(seconds: 1), () => pancakes);
//   }

//   @override
//   Future<void> deletePancake(String id) async {
//     pancakes.removeWhere((element) => element.id == id);
//   }

//   @override
//   Future<void> updatePancake(
//       {required String id, required String color, required double price}) async {
//     final index = pancakes.indexWhere((element) => element.id == id);
//     if (index != -1) {
//       pancakes[index] = Pancake(id: id, color: color, price: price);
//     }
//   }
// }

// MODEL & DTO
class PancakeDto {
  static Pancake fromJson(String id, Map<String, dynamic> json) {
    return Pancake(id: id, color: json['color'], price: json['price']);
  }

  static Map<String, dynamic> toJson(Pancake pancake) {
    return {'name': pancake.color, 'price': pancake.price};
  }
}

// MODEL
class Pancake {
  final String id;
  final String color;
  final double price;

  Pancake({required this.id, required this.color, required this.price});

  @override
  bool operator ==(Object other) {
    return other is Pancake && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// PROVIDER
class PancakeProvider extends ChangeNotifier {
  final PancakeRepository _repository;
  AsyncValue<List<Pancake>>? pancakesState;
  Pancake? selectedPancake;

  PancakeProvider(this._repository) {
    fetchPancakes();
  }

  bool get isLoading => pancakesState != null && pancakesState!.state == AsyncValueState.loading;
  bool get hasData => pancakesState != null && pancakesState!.state == AsyncValueState.success;

  void fetchPancakes() async {
    try {
      // 1- loading state
      pancakesState = AsyncValue.loading();
      notifyListeners();
      // 2- fetch data
      pancakesState = AsyncValue.success(await _repository.getPancakes());
      print("SUCCESS: list size ${pancakesState!.data!.length.toString()}");
      // 3- Handle errors
    } catch (error) {
      print("ERROR: $error");
      pancakesState = AsyncValue.error(error);
    }
    notifyListeners();
  }

  void addPancake(String color, double price) async {
    // 1- Call repo to add
    await _repository.addPancake(color: color, price: price);
    // 2- Fetch pancakes again
    fetchPancakes();
  }

  void deletePancake(String id) async {
    // 1- Call repo to delete
    await _repository.deletePancake(id);
    // 2- Fetch pancakes to refresh
    fetchPancakes();

  }

  void updatePancake(String id, String color, double price) async {
    await _repository.updatePancake(id: id, color: color, price: price);
    fetchPancakes();
  }

  void setSelectedPancake(Pancake? pancake) {
    selectedPancake = pancake;
    notifyListeners();
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Pancakes', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PancakeFormPage()),
              );
            },
          ),
        ],
      ),
      body: const PancakeList(),
    );
  }
}

class PancakeList extends StatelessWidget {
  const PancakeList({super.key});

  @override
  Widget build(BuildContext context) {
    final pancakeProvider = Provider.of<PancakeProvider>(context);

    if (pancakeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (pancakeProvider.hasData) {
      final pancakes = pancakeProvider.pancakesState!.data!;

      if (pancakes.isEmpty) {
        return const Center(child: Text("No data yet"));
      } else {
        return ListView.builder(
          itemCount: pancakes.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(pancakes[index].color),
            subtitle: Text("${pancakes[index].price}"),
            onTap: () {
              pancakeProvider.setSelectedPancake(pancakes[index]);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PancakeFormPage()),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  pancakeProvider.deletePancake(pancakes[index].id),
            ),
          ),
        );
      }
    } else {
      return const Center(child: Text('Error loading pancakes'));
    }
  }
}

class PancakeFormPage extends StatefulWidget {
  const PancakeFormPage({super.key});

  @override
  State<PancakeFormPage> createState() => _PancakeFormPageState();
}

class _PancakeFormPageState extends State<PancakeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pancakeProvider = Provider.of<PancakeProvider>(context, listen: false);
    if (pancakeProvider.selectedPancake != null) {
      _colorController.text = pancakeProvider.selectedPancake!.color;
      _priceController.text = pancakeProvider.selectedPancake!.price.toString();
    } else {
      _colorController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pancakeProvider = Provider.of<PancakeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(pancakeProvider.selectedPancake == null ? 'Add Pancake' : 'Update Pancake')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter color' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null
                    ? 'Enter valid price'
                    : null,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (pancakeProvider.selectedPancake == null) {
                      pancakeProvider.addPancake(
                          _colorController.text, double.parse(_priceController.text));
                    } else {
                      pancakeProvider.updatePancake(
                          pancakeProvider.selectedPancake!.id,
                          _colorController.text,
                          double.parse(_priceController.text));
                      pancakeProvider.setSelectedPancake(null);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(pancakeProvider.selectedPancake == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 5 - MAIN
void main() async {
  final PancakeRepository pancakeRepository = FirebasePancakeRepository();

  runApp(
    ChangeNotifierProvider(
      create: (context) => PancakeProvider(pancakeRepository),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: const App()),
    ),
  );
}