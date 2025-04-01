import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w8/W8-Practice-Crud/repository/pancake_repository.dart';
import 'package:w8/W8-Practice-Crud/widgets/pancake_form.dart';

import 'provider/pancake_provider.dart';
import 'repository/firebase_pancake_repository.dart';
import 'widgets/pancake_list.dart';

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