import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagoScreen extends StatefulWidget {
  final String reservaId;

  PagoScreen({required this.reservaId});

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  bool _senalPagada = false;
  bool _contratoFirmado = false;
  double _montoSenal = 150.0; // Ejemplo: 10% del total

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago y Contrato'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la reserva
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserva #${widget.reservaId.substring(0, 8)}',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Seña requerida: \$${_montoSenal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Pago de señal
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _senalPagada
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: _senalPagada
                              ? Colors.green
                              : Colors.grey,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Pago de Seña',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (!_senalPagada) ...[
                      // Simulación de pasarela de pago
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _senalPagada = true);
                          _simularPago();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'PAGAR SEÑA DE \$${_montoSenal.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else
                      Text(
                        'Seña pagada exitosamente',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Firma de contrato
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _contratoFirmado
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: _contratoFirmado
                              ? Colors.green
                              : Colors.grey,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Contrato Digital',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Vista previa del contrato
                    Container(
                      height: 200,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          '''
CONTRATO DE ALQUILER MOBIEVENT

Cliente: [Nombre del Cliente]
Fecha: [Fecha Actual]

1. OBJETO: Alquiler de mobiliario para eventos.
2. DURACIÓN: Desde [Fecha Inicio] hasta [Fecha Fin].
3. VALOR TOTAL: [Monto Total]
4. SEÑA: [Monto Seña] (30% del total)
5. CONDICIONES:
   - El mobiliario debe ser devuelto en el mismo estado.
   - Se aplican cargos por daños.
   - La reprogramación requiere 48 horas de anticipación.

FIRMA DEL CLIENTE:
_________________________
''',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    if (!_contratoFirmado) ...[
                      ElevatedButton(
                        onPressed: _senalPagada
                            ? () {
                                setState(() => _contratoFirmado = true);
                                _finalizarReserva();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF9800),
                          minimumSize: Size(double.infinity, 50),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: Text(
                          'FIRMAR CONTRATO DIGITALMENTE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else
                      Text(
                        'Contrato firmado exitosamente',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
            ),

            Spacer(),

            if (_senalPagada && _contratoFirmado)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle,
                        size: 80, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      '¡Reserva Confirmada!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Recibirás un correo con los detalles',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _simularPago() async {
    // Simular proceso de pago
    await Future.delayed(Duration(seconds: 2));
    
    // Actualizar en Firestore
    final firestore = Provider.of<FirebaseFirestore>(context, listen: false);
    await firestore
        .collection('reservas')
        .doc(widget.reservaId)
        .update({'senalPagada': true});
  }

  void _finalizarReserva() async {
    // Actualizar en Firestore
    final firestore = Provider.of<FirebaseFirestore>(context, listen: false);
    await firestore.collection('reservas').doc(widget.reservaId).update({
      'contratoFirmado': true,
      'estado': 'confirmada',
    });
  }
}