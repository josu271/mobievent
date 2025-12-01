import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';

class TransportScreen extends StatefulWidget {
  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TextEditingController _addressController = TextEditingController();
  String _estimatedDistance = '0';
  
  Future<void> _calculateTransport() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    // Aquí integrarías con una API de mapas para calcular distancia
    // Ejemplo simulado:
    final simulatedDistance = 15.5; // km
    
    final cost = await firestoreService.calculateTransportCost(simulatedDistance);
    
    setState(() {
      _estimatedDistance = simulatedDistance.toStringAsFixed(1);
      // Actualizar coste en reserva
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Costo de transporte: \$${cost.toStringAsFixed(2)} para $_estimatedDistance km')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar Transporte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Dirección de entrega',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateTransport,
              child: Text('Calcular Costo de Transporte'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Resumen de Transporte', 
                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Distancia estimada: $_estimatedDistance km'),
                    Text('Dirección: ${_addressController.text}'),
                  ],
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              child: Text('Continuar al Pago'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}