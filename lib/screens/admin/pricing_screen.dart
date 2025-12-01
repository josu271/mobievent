import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';

class PricingScreen extends StatefulWidget {
  @override
  _PricingScreenState createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseCostController = TextEditingController(text: '50.0');
  final TextEditingController _costPerKmController = TextEditingController(text: '10.0');
  final TextEditingController _minimumDistanceController = TextEditingController(text: '5.0');
  
  Future<void> _savePricing() async {
    if (_formKey.currentState!.validate()) {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final baseCost = double.parse(_baseCostController.text);
      final costPerKm = double.parse(_costPerKmController.text);
      final minimumDistance = double.parse(_minimumDistanceController.text);
      
      await firestoreService.updateTransportPricing(baseCost, costPerKm, minimumDistance);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarifas actualizadas correctamente')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar Tarifas de Transporte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _baseCostController,
                decoration: InputDecoration(
                  labelText: 'Costo base (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un valor';
                  if (double.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _costPerKmController,
                decoration: InputDecoration(
                  labelText: 'Costo por kilómetro (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un valor';
                  if (double.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _minimumDistanceController,
                decoration: InputDecoration(
                  labelText: 'Distancia mínima (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un valor';
                  if (double.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePricing,
                child: Text('Guardar Tarifas'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fórmula de cálculo:', 
                           style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Costo = Base + (Distancia × Costo/km)'),
                      Text('Distancia mínima aplicada: ${_minimumDistanceController.text} km'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}