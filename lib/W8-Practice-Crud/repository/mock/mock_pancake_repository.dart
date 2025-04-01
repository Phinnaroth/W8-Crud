import '../../model/pancake.dart';
import '../pancake_repository.dart';

class MockPancakeRepository extends PancakeRepository {
  final List<Pancake> pancakes = [];

  @override
  Future<Pancake> addPancake({required String color, required double price}) {
    return Future.delayed(Duration(seconds: 1), () {
      Pancake newPancake = Pancake(id: "0", color: color, price: price);
      pancakes.add(newPancake);
      return newPancake;
    });
  }

  @override
  Future<List<Pancake>> getPancakes() {
    return Future.delayed(Duration(seconds: 1), () => pancakes);
  }

  @override
  Future<void> deletePancake(String id) async {
    pancakes.removeWhere((element) => element.id == id);
  }

  @override
  Future<void> updatePancake(
      {required String id, required String color, required double price}) async {
    final index = pancakes.indexWhere((element) => element.id == id);
    if (index != -1) {
      pancakes[index] = Pancake(id: id, color: color, price: price);
    }
  }
}