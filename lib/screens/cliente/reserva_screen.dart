import 'package:flutter/material.dart';
import 'package:mobievent/screens/cliente/mapa_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/reserva_service.dart';

class ReservaScreen extends StatefulWidget {
  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _inventarioDisponible = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarInventario();
    });
  }

  Future<void> _cargarInventario() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    try {
      final reservaService = Provider.of<ReservaService>(context, listen: false);
      final inventario = await reservaService.getInventarioDisponible(_selectedDate);
      setState(() {
        _inventarioDisponible = inventario;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error al cargar inventario: $e';
      });
      print('Error en _cargarInventario: $e');
    }
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
      });
      _cargarInventario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Mobiliario'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Selector de fecha
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha seleccionada:',
                    style: TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de inventario disponible
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 50),
                              SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _cargarInventario,
                                child: Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _inventarioDisponible.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory, size: 60, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No hay mobiliario disponible para esta fecha',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: _inventarioDisponible.length,
                            itemBuilder: (context, index) {
                              final lote = _inventarioDisponible[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: ListTile(
                                  leading: Icon(Icons.event_seat,
                                      color: Color(0xFF2E7D32)),
                                  title: Text(
                                    lote['nombre'] ?? 'Sin nombre',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(lote['descripcion'] ?? 'Sin descripcion'),
                                      SizedBox(height: 4),
                                      Text(
                                        'Precio: \$${(lote['tarifaLote'] ?? 0).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32)),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      _mostrarDetallesReserva(lote);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF9800),
                                    ),
                                    child: Text('Reservar'),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesReserva(Map<String, dynamic> lote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DetallesReservaSheet(lote: lote, fecha: _selectedDate);
      },
    );
  }
}

class DetallesReservaSheet extends StatefulWidget {
  final Map<String, dynamic> lote;
  final DateTime fecha;

  DetallesReservaSheet({required this.lote, required this.fecha});

  @override
  _DetallesReservaSheetState createState() => _DetallesReservaSheetState();
}

class _DetallesReservaSheetState extends State<DetallesReservaSheet> {
  int _dias = 1;
  String _direccionEntrega = '';
  double _distanciaKm = 0;
  double _costoTransporte = 0;
  bool _calculandoTransporte = false;

  @override
  Widget build(BuildContext context) {
    final double costoTotal =
        ((widget.lote['tarifaLote'] ?? 0) * _dias) + _costoTransporte;

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lote['nombre'] ?? 'Lote sin nombre',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Descripcion: ${widget.lote['descripcion'] ?? 'Sin descripcion'}'),
          SizedBox(height: 16),
          
          // Selector de dias
          Row(
            children: [
              Text('Dias de alquiler:'),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (_dias > 1) {
                    setState(() => _dias--);
                  }
                },
              ),
              Text('$_dias', style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => setState(() => _dias++),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Transporte
          TextField(
            decoration: InputDecoration(
              labelText: 'Direccion de entrega',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.location_on),
            ),
            onChanged: (value) => _direccionEntrega = value,
          ),
          
          SizedBox(height: 16),
          
          // Boton para calcular distancia
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapaScreen(
          onUbicacionSeleccionada: (distancia, direccion) {
            setState(() {
              _distanciaKm = distancia;
              _direccionEntrega = direccion;
              // Calcular costo de transporte usando el servicio
              _costoTransporte = distancia * 10; // Puedes usar tu lógica de cálculo
            });
          },
        ),
      ),
    );
  },
  icon: Icon(Icons.map),
  label: Text('Seleccionar ubicacion en mapa'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2E7D32),
    minimumSize: Size(double.infinity, 50),
  ),
),
          
          if (_distanciaKm > 0) ...[
            SizedBox(height: 16),
            Text('Distancia: ${_distanciaKm.toStringAsFixed(1)} km'),
            Text('Costo transporte: \$${_costoTransporte.toStringAsFixed(2)}'),
          ],
          
          SizedBox(height: 24),
          
          // Resumen de costo
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alquiler (${_dias} dias):'),
                      Text(
                          '\$${((widget.lote['tarifaLote'] ?? 0) * _dias).toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transporte:'),
                      Text('\$${_costoTransporte.toStringAsFixed(2)}'),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${costoTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF2E7D32))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Boton de reserva
          ElevatedButton(
            onPressed: () {
              _confirmarReserva(costoTotal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9800),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'CONFIRMAR RESERVA',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarReserva(double costoTotal) async {
    try {
      final reservaService = Provider.of<ReservaService>(context, listen: false);
      
      // Simular usuario autenticado - en produccion obtendrias del auth
      final usuarioId = 'cliente_actual';
      
      final reservaId = await reservaService.crearReserva(
        clienteId: usuarioId,
        loteId: widget.lote['id'] ?? '',
        fechaInicio: widget.fecha,
        fechaFin: widget.fecha.add(Duration(days: _dias - 1)),
        costoTotal: costoTotal,
        direccionEntrega: _direccionEntrega.isNotEmpty ? _direccionEntrega : null,
        distanciaKm: _distanciaKm > 0 ? _distanciaKm : null,
      );
      
      Navigator.pop(context);
      
      // Mostrar mensaje de exito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Reserva creada exitosamente! Procede al pago.'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear reserva: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}