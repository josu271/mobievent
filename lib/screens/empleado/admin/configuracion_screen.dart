import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tarifaKmController = TextEditingController();
  final _diasMinimosController = TextEditingController();
  final _porcentajeSenalController = TextEditingController();
  
  final _tarifaMesaController = TextEditingController();
  final _tarifaSillaController = TextEditingController();
  final _tarifaEscenarioController = TextEditingController();
  final _tarifaDecoracionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final configDoc = await FirebaseFirestore.instance
          .collection('configuraciones')
          .doc('tarifas')
          .get();

      if (configDoc.exists) {
        final data = configDoc.data()!;
        setState(() {
          _tarifaKmController.text = data['tarifaPorKm']?.toString() ?? '10.0';
          _diasMinimosController.text = data['diasMinimosReprogramacion']?.toString() ?? '2';
          _porcentajeSenalController.text = data['porcentajeSenal']?.toString() ?? '30';
        });
      }

      // Cargar tarifas por tipo de artículo
      final tarifasDoc = await FirebaseFirestore.instance
          .collection('configuraciones')
          .doc('tarifasArticulos')
          .get();

      if (tarifasDoc.exists) {
        final data = tarifasDoc.data()!;
        setState(() {
          _tarifaMesaController.text = data['mesa']?.toString() ?? '15.0';
          _tarifaSillaController.text = data['silla']?.toString() ?? '5.0';
          _tarifaEscenarioController.text = data['escenario']?.toString() ?? '50.0';
          _tarifaDecoracionController.text = data['decoracion']?.toString() ?? '20.0';
        });
      }
    } catch (e) {
      print('Error al cargar configuración: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración del Sistema'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarifas de transporte
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarifas de Transporte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _tarifaKmController,
                        decoration: InputDecoration(
                          labelText: 'Tarifa por kilómetro (\$)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la tarifa por km';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Políticas
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Políticas del Sistema',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _diasMinimosController,
                        decoration: InputDecoration(
                          labelText: 'Días mínimos para reprogramación',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el número de días';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _porcentajeSenalController,
                        decoration: InputDecoration(
                          labelText: 'Porcentaje de seña (%)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el porcentaje';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          if (int.parse(value) < 0 || int.parse(value) > 100) {
                            return 'Ingrese un porcentaje válido (0-100)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Tarifas por tipo de artículo
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarifas por Tipo de Artículo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _tarifaMesaController,
                        decoration: InputDecoration(
                          labelText: 'Tarifa por mesa (\$/día)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.table_restaurant),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _tarifaSillaController,
                        decoration: InputDecoration(
                          labelText: 'Tarifa por silla (\$/día)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.chair),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _tarifaEscenarioController,
                        decoration: InputDecoration(
                          labelText: 'Tarifa por escenario (\$/día)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _tarifaDecoracionController,
                        decoration: InputDecoration(
                          labelText: 'Tarifa por decoración (\$/día)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.celebration),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Botón de guardar
              ElevatedButton(
                onPressed: _guardarConfiguracion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'GUARDAR CONFIGURACIÓN',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Guardar tarifas de transporte y políticas
      await FirebaseFirestore.instance
          .collection('configuraciones')
          .doc('tarifas')
          .set({
        'tarifaPorKm': double.parse(_tarifaKmController.text),
        'diasMinimosReprogramacion': int.parse(_diasMinimosController.text),
        'porcentajeSenal': int.parse(_porcentajeSenalController.text),
        'actualizado': DateTime.now(),
      }, SetOptions(merge: true));

      // Guardar tarifas por tipo de artículo
      await FirebaseFirestore.instance
          .collection('configuraciones')
          .doc('tarifasArticulos')
          .set({
        'mesa': double.parse(_tarifaMesaController.text),
        'silla': double.parse(_tarifaSillaController.text),
        'escenario': double.parse(_tarifaEscenarioController.text),
        'decoracion': double.parse(_tarifaDecoracionController.text),
        'actualizado': DateTime.now(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuración guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar configuración: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tarifaKmController.dispose();
    _diasMinimosController.dispose();
    _porcentajeSenalController.dispose();
    _tarifaMesaController.dispose();
    _tarifaSillaController.dispose();
    _tarifaEscenarioController.dispose();
    _tarifaDecoracionController.dispose();
    super.dispose();
  }
}