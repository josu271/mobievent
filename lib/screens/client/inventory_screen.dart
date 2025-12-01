import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/models.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<ReservationItem> _selectedItems = [];
  double _transportCost = 0.0;
  
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario Disponible'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Fecha seleccionada: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: firestoreService.getAvailableProducts(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar productos'));
                }
                
                final products = snapshot.data ?? [];
                
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(product.category[0]),
                        ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.description),
                            Text('\$${product.pricePerDay.toStringAsFixed(2)} por día'),
                            Text('Disponible: ${product.quantity} unidades'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _removeItem(product.id),
                            ),
                            Text(_getItemQuantity(product.id).toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _addItem(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildReservationSummary(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedItems.isNotEmpty ? () => _createReservation(context) : null,
        label: Text('Reservar'),
        icon: Icon(Icons.check),
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedItems.clear();
      });
    }
  }
  
  void _addItem(Product product) {
    setState(() {
      final existingIndex = _selectedItems.indexWhere((item) => item.productId == product.id);
      if (existingIndex >= 0) {
        _selectedItems[existingIndex] = ReservationItem(
          productId: product.id,
          productName: product.name,
          quantity: _selectedItems[existingIndex].quantity + 1,
          pricePerDay: product.pricePerDay,
        );
      } else {
        _selectedItems.add(ReservationItem(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          pricePerDay: product.pricePerDay,
        ));
      }
    });
  }
  
  void _removeItem(String productId) {
    setState(() {
      final existingIndex = _selectedItems.indexWhere((item) => item.productId == productId);
      if (existingIndex >= 0) {
        if (_selectedItems[existingIndex].quantity > 1) {
          _selectedItems[existingIndex] = ReservationItem(
            productId: productId,
            productName: _selectedItems[existingIndex].productName,
            quantity: _selectedItems[existingIndex].quantity - 1,
            pricePerDay: _selectedItems[existingIndex].pricePerDay,
          );
        } else {
          _selectedItems.removeAt(existingIndex);
        }
      }
    });
  }
  
  int _getItemQuantity(String productId) {
    final item = _selectedItems.firstWhere((item) => item.productId == productId, orElse: () => ReservationItem(productId: '', productName: '', quantity: 0, pricePerDay: 0));
    return item.quantity;
  }
  
  Widget _buildReservationSummary() {
    final totalDays = 1; // Simplificado, normalmente sería endDate - startDate
    final subtotal = _selectedItems.fold(0.0, (sum, item) => sum + (item.quantity * item.pricePerDay * totalDays));
    final deposit = subtotal * 0.3; // 30% de señal
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resumen de Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Productos seleccionados: ${_selectedItems.length}'),
            Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
            Text('Señal (30%): \$${deposit.toStringAsFixed(2)}'),
            Text('Costo transporte: \$${_transportCost.toStringAsFixed(2)}'),
            Divider(),
            Text('Total estimado: \$${(subtotal + _transportCost).toStringAsFixed(2)}', 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  
  Future<void> _createReservation(BuildContext context) async {
    // Implementar creación de reserva
    // Navegar a pantalla de transporte (HU-C2)
    Navigator.pushNamed(context, '/transport');
  }
}