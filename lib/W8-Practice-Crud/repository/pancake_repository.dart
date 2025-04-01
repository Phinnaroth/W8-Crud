import '../model/pancake.dart';

abstract class PancakeRepository {
  Future<Pancake> addPancake({required String color, required double price});
  Future<List<Pancake>> getPancakes();
  Future<void> updatePancake({required String id, required String color, required double price});
  Future<void> deletePancake(String id) async {}
}