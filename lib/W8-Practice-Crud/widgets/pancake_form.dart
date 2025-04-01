import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/pancake_provider.dart';

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