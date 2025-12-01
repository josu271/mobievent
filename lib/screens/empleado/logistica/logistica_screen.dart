import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogisticaScreen extends StatefulWidget {
  @override
  _LogisticaScreenState createState() => _LogisticaScreenState();
}

class _LogisticaScreenState extends State<LogisticaScreen> {
  final List<String> _vehiculos = [
    'Camion Grande - ABC123',
    'Camion Mediano - DEF456',
    'Furgoneta - GHI789',
    'Pickup - JKL012',
  ];
  String? _selectedVehiculo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Logistica'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Selector de vehiculo
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asignar Vehiculo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedVehiculo,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar vehiculo',
                      border: OutlineInputBorder(),
                    ),
                    items: _vehiculos.map((vehiculo) {
                      return DropdownMenuItem(
                        value: vehiculo,
                        child: Text(vehiculo),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedVehiculo = value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Lista de entregas pendientes
          Expanded(
            child: _buildEntregasPendientes(),
          ),
        ],
      ),
    );
  }

  Widget _buildEntregasPendientes() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('transporte')
          .where('estado', isEqualTo: 'pendiente')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No hay entregas pendientes'),
          );
        }

        final entregas = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: entregas.length,
          itemBuilder: (context, index) {
            final entrega = entregas[index];
            final data = entrega.data() as Map<String, dynamic>;

            return FutureBuilder(
              future: _getReservaInfo(data['reservaId']),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> reservaSnapshot) {
                if (!reservaSnapshot.hasData) {
                  return SizedBox.shrink();
                }

                final reservaInfo = reservaSnapshot.data!;

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Entrega #${entrega.id.substring(0, 8)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Chip(
                              label: Text('PENDIENTE'),
                              backgroundColor: Colors.orange,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('Direccion: ${data['direccionEntrega']}'),
                        SizedBox(height: 8),
                        Text('Distancia: ${data['distanciaKm']?.toStringAsFixed(1) ?? '0'} km'),
                        SizedBox(height: 8),
                        Text('Costo transporte: \$${data['costoTransporte']?.toStringAsFixed(2) ?? '0'}'),
                        SizedBox(height: 8),
                        if (reservaInfo['cliente'] != null)
                          Text('Cliente: ${reservaInfo['cliente']}'),
                        
                        SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _mostrarDetallesMapa(data['direccionEntrega']);
                                },
                                child: Text('VER RUTA'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _selectedVehiculo != null
                                    ? () {
                                        _asignarVehiculo(entrega.id, _selectedVehiculo!);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2E7D32),
                                ),
                                child: Text('ASIGNAR'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getReservaInfo(String reservaId) async {
    try {
      final reservaDoc = await FirebaseFirestore.instance
          .collection('reservas')
          .doc(reservaId)
          .get();

      if (!reservaDoc.exists) return {};

      final reservaData = reservaDoc.data()!;
      final clienteId = reservaData['clienteId'];

      // Obtener informacion del cliente
      final clienteDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(clienteId)
          .get();

      String clienteNombre = 'Cliente no encontrado';
      if (clienteDoc.exists) {
        clienteNombre = clienteDoc.data()?['nombre'] ?? 'Cliente';
      }

      return {
        'cliente': clienteNombre,
        'fecha': (reservaData['fechaInicio'] as Timestamp).toDate(),
      };
    } catch (e) {
      print('Error al obtener info de reserva: $e');
      return {};
    }
  }

  void _mostrarDetallesMapa(String direccion) {
    // Implementar vista de mapa con la ruta
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ruta de entrega'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green),
                  title: Text('Almacen MobiEvent'),
                  subtitle: Text('Punto de origen'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.red),
                  title: Text('Destino'),
                  subtitle: Text(direccion),
                ),
                SizedBox(height: 16),
                Text('Distancia estimada: 15.5 km'),
                Text('Tiempo estimado: 45 minutos'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CERRAR'),
            ),
          ],
        );
      },
    );
  }

  void _asignarVehiculo(String entregaId, String vehiculo) async {
    try {
      await FirebaseFirestore.instance
          .collection('transporte')
          .doc(entregaId)
          .update({
        'vehiculoAsignado': vehiculo,
        'estado': 'asignado',
        'fechaAsignacion': DateTime.now(),
      });

      // Actualizar estado de la reserva
      final entregaDoc = await FirebaseFirestore.instance
          .collection('transporte')
          .doc(entregaId)
          .get();
      
      final reservaId = entregaDoc.data()!['reservaId'];
      
      await FirebaseFirestore.instance
          .collection('reservas')
          .doc(reservaId)
          .update({'estado': 'asignada'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehiculo asignado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al asignar vehiculo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}