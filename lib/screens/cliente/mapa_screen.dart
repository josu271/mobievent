import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaScreen extends StatefulWidget {
  final Function(double) onDistanciaCalculada;

  MapaScreen({required this.onDistanciaCalculada});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _origen;
  LatLng? _destino;
  double _distanciaKm = 0;

  // Coordenadas del almacén (ubicación fija)
  static final LatLng _almacen = LatLng(-12.0464, -77.0428); // Lima, Perú

  @override
  void initState() {
    super.initState();
    _agregarMarcadorAlmacen();
  }

  void _agregarMarcadorAlmacen() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('almacen'),
          position: _almacen,
          infoWindow: InfoWindow(
            title: 'Almacén MobiEvent',
            snippet: 'Punto de recogida',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicación de Entrega'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _almacen,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) {
              _agregarMarcadorDestino(position);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          
          // Panel inferior con información
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('1. Toque en el mapa para marcar la dirección de entrega'),
                    Text('2. Se calculará la distancia desde el almacén'),
                    SizedBox(height: 16),
                    
                    if (_destino != null) ...[
                      Divider(),
                      Text(
                        'Distancia calculada:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('${_distanciaKm.toStringAsFixed(1)} km'),
                      SizedBox(height: 16),
                      
                      ElevatedButton(
                        onPressed: () {
                          widget.onDistanciaCalculada(_distanciaKm);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('CONFIRMAR UBICACIÓN'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _limpiarMarcadores,
        backgroundColor: Color(0xFFFF9800),
        child: Icon(Icons.refresh),
      ),
    );
  }

  void _agregarMarcadorDestino(LatLng position) {
    setState(() {
      // Remover marcador anterior si existe
      _markers.removeWhere((marker) => marker.markerId.value == 'destino');
      
      // Agregar nuevo marcador
      _markers.add(
        Marker(
          markerId: MarkerId('destino'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Dirección de Entrega',
            snippet: 'Toque para más información',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      
      _destino = position;
      _calcularDistancia();
    });
  }

  void _calcularDistancia() {
    if (_origen == null || _destino == null) return;

    // Calcular distancia usando fórmula de Haversine
    _distanciaKm = _calcularDistanciaHaversine(_almacen, _destino!);

    // Crear polyline entre los puntos
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId('ruta'),
        color: Colors.blue,
        width: 4,
        points: [_almacen, _destino!],
      ),
    );

    setState(() {});
  }

  double _calcularDistanciaHaversine(LatLng punto1, LatLng punto2) {
    const double radioTierra = 6371; // Radio de la Tierra en km

    double lat1 = punto1.latitude * (3.14159265358979323846 / 180);
    double lon1 = punto1.longitude * (3.14159265358979323846 / 180);
    double lat2 = punto2.latitude * (3.14159265358979323846 / 180);
    double lon2 = punto2.longitude * (3.14159265358979323846 / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radioTierra * c;
  }

  void _limpiarMarcadores() {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'destino');
      _polylines.clear();
      _destino = null;
      _distanciaKm = 0;
    });
  }
}