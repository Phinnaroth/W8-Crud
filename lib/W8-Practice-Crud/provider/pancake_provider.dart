import 'package:flutter/material.dart';

import '../async_value.dart';
import '../model/pancake.dart';
import '../repository/pancake_repository.dart';

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
