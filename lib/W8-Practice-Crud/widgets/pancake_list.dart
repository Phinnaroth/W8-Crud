import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/pancake_provider.dart';
import 'pancake_form.dart';

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