import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlmacenScreen extends StatefulWidget {
  @override
  _AlmacenScreenState createState() => _AlmacenScreenState();
}

class _AlmacenScreenState extends State<AlmacenScreen> {
  List<DocumentSnapshot> _reservasPendientes = [];
  List<DocumentSnapshot> _reservasPreparadas = [];

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  void _cargarReservas() async {
    final firestore = FirebaseFirestore.instance;
    
    // Reservas pendientes de preparación
    final pendientesSnapshot = await firestore
        .collection('reservas')
        .where('estado', isEqualTo: 'confirmada')
        .get();
    
    // Reservas en preparación
    final preparadasSnapshot = await firestore
        .collection('reservas')
        .where('estado', isEqualTo: 'en_preparacion')
        .get();

    setState(() {
      _reservasPendientes = pendientesSnapshot.docs;
      _reservasPreparadas = preparadasSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel de Almacén'),
          backgroundColor: Color(0xFF2E7D32),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: 'Pendientes (${_reservasPendientes.length})',
              ),
              Tab(
                icon: Icon(Icons.inventory),
                text: 'En Preparación (${_reservasPreparadas.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de pendientes
            _buildListaReservas(_reservasPendientes, 'pendiente'),
            
            // Pestaña en preparación
            _buildListaReservas(_reservasPreparadas, 'preparacion'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _mostrarReporteInventario();
          },
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.assessment),
        ),
      ),
    );
  }

  Widget _buildListaReservas(List<DocumentSnapshot> reservas, String tipo) {
    if (reservas.isEmpty) {
      return Center(
        child: Text(
          'No hay reservas ${tipo == 'pendiente' ? 'pendientes' : 'en preparación'}',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        final data = reserva.data() as Map<String, dynamic>;
        
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
                      'Reserva #${reserva.id.substring(0, 8)}',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(
                        data['estado'].toString().toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: _getColorEstado(data['estado']),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Entrega: ${DateFormat('dd/MM/yyyy').format((data['fechaInicio'] as Timestamp).toDate())}',
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                if (data['direccionEntrega'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dirección: ${data['direccionEntrega']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Total: \$${data['costoTotal'].toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                if (tipo == 'pendiente')
                  ElevatedButton(
                    onPressed: () {
                      _iniciarPreparacion(reserva.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9800),
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: Text('INICIAR PREPARACIÓN'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      _completarPreparacion(reserva.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: Text('MARCAR COMO PREPARADO'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return Colors.blue;
      case 'en_preparacion':
        return Colors.orange;
      case 'preparada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _iniciarPreparacion(String reservaId) async {
    final firestore = FirebaseFirestore.instance;
    
    // Actualizar estado de la reserva
    await firestore
        .collection('reservas')
        .doc(reservaId)
        .update({'estado': 'en_preparacion'});
    
    // Bloquear items del inventario (simulación)
    await _bloquearInventario(reservaId);
    
    // Recargar lista
    _cargarReservas();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preparación iniciada - Items bloqueados'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _bloquearInventario(String reservaId) async {
    final firestore = FirebaseFirestore.instance;
    
    // Obtener reserva
    final reservaDoc = await firestore.collection('reservas').doc(reservaId).get();
    final reservaData = reservaDoc.data()!;
    final loteId = reservaData['loteId'];
    
    // Obtener lote
    final loteDoc = await firestore.collection('lotes').doc(loteId).get();
    final loteData = loteDoc.data()!;
    final articulos = loteData['articulos'] as Map<String, dynamic>;
    
    // Actualizar disponibilidad de cada artículo
    for (var articuloId in articulos.keys) {
      await firestore.collection('articulos').doc(articuloId).update({
        'cantidadDisponible': FieldValue.increment(-articulos[articuloId]),
      });
    }
  }

  void _completarPreparacion(String reservaId) async {
    final firestore = FirebaseFirestore.instance;
    
    await firestore
        .collection('reservas')
        .doc(reservaId)
        .update({'estado': 'preparada'});
    
    // Crear registro de transporte
    await firestore.collection('transporte').add({
      'reservaId': reservaId,
      'estado': 'pendiente',
      'fechaPreparacion': Timestamp.now(),
    });
    
    _cargarReservas();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva marcada como preparada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarReporteInventario() async {
    final firestore = FirebaseFirestore.instance;
    
    // Obtener todos los artículos
    final articulosSnapshot = await firestore.collection('articulos').get();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reporte de Inventario'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: articulosSnapshot.docs.length,
              itemBuilder: (context, index) {
                final articulo = articulosSnapshot.docs[index];
                final data = articulo.data();
                
                final total = data['cantidadTotal'] ?? 0;
                final disponible = data['cantidadDisponible'] ?? 0;
                final ocupado = total - disponible;
                final porcentajeOcupacion = total > 0 ? (ocupado / total * 100) : 0;
                
                return ListTile(
                  leading: Icon(Icons.inventory, color: Color(0xFF2E7D32)),
                  title: Text(data['nombre']),
                  subtitle: Text('${data['tipo']} - \$${data['tarifaPorDia']}/día'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$disponible/$total disp.'),
                      Text(
                        '${porcentajeOcupacion.toStringAsFixed(0)}% ocup.',
                        style: TextStyle(
                          color: porcentajeOcupacion > 80
                              ? Colors.red
                              : porcentajeOcupacion > 50
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}