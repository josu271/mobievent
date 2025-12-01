import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/geolocation_service.dart';

class MapaScreen extends StatefulWidget {
  final Function(double, String) onUbicacionSeleccionada;

  MapaScreen({required this.onUbicacionSeleccionada});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _ubicacionActual;
  LatLng? _destinoSeleccionado;
  double _distanciaKm = 0;
  String _direccionCompleta = '';
  bool _cargando = true;
  final GeoLocationService _geoService = GeoLocationService();

  // Coordenadas del almacen (puedes cambiarlas)
  static final LatLng _almacenUbicacion = LatLng(-12.0464, -77.0428); // Lima, Peru

  @override
  void initState() {
    super.initState();
    _inicializarMapa();
  }

  Future<void> _inicializarMapa() async {
    try {
      // Obtener ubicacion actual del usuario
      final Position posicion = await _geoService.getCurrentLocation();
      setState(() {
        _ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
        _cargando = false;
      });
      
      // Agregar marcadores
      _agregarMarcadores();
    } catch (e) {
      print('Error al obtener ubicacion: $e');
      // Usar ubicacion por defecto si hay error
      setState(() {
        _ubicacionActual = _almacenUbicacion;
        _cargando = false;
      });
      _agregarMarcadores();
    }
  }

  void _agregarMarcadores() {
    setState(() {
      // Marcador del almacen
      _markers.add(
        Marker(
          markerId: MarkerId('almacen'),
          position: _almacenUbicacion,
          infoWindow: InfoWindow(
            title: 'Almacen MobiEvent',
            snippet: 'Punto de recogida',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Marcador de ubicacion actual si existe
      if (_ubicacionActual != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('ubicacion_actual'),
            position: _ubicacionActual!,
            infoWindow: InfoWindow(
              title: 'Tu ubicacion',
              snippet: 'Ubicacion actual',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }
    });
  }

  Future<void> _calcularDistanciaYDireccion(LatLng destino) async {
    try {
      // Calcular distancia
      _distanciaKm = _geoService.calculateDistance(
        _almacenUbicacion.latitude,
        _almacenUbicacion.longitude,
        destino.latitude,
        destino.longitude,
      );

      // Obtener direccion completa
      _direccionCompleta = await _geoService.getAddressFromCoordinates(
        destino.latitude,
        destino.longitude,
      );

      // Crear polyline entre almacen y destino
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('ruta_entrega'),
          color: Colors.blue,
          width: 4,
          points: [_almacenUbicacion, destino],
        ),
      );

      setState(() {});
    } catch (e) {
      print('Error al calcular distancia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicacion de Entrega'),
        backgroundColor: Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _ubicacionActual != null ? _centrarEnUbicacionActual : null,
          ),
        ],
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _ubicacionActual ?? _almacenUbicacion,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng position) {
                    _seleccionarUbicacion(position);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                
                // Boton de ubicacion actual
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _ubicacionActual != null ? _centrarEnUbicacionActual : null,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.my_location, color: Color(0xFF2E7D32)),
                  ),
                ),
                
                // Panel inferior con informacion
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildPanelInferior(),
                ),
              ],
            ),
    );
  }

  Widget _buildPanelInferior() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instrucciones:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 8),
            Text('1. Toca en el mapa para marcar la direccion de entrega'),
            Text('2. Se calculara la distancia desde el almacen'),
            SizedBox(height: 16),
            
            if (_destinoSeleccionado != null) ...[
              Divider(),
              Text(
                'Direccion seleccionada:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _direccionCompleta.isNotEmpty 
                    ? _direccionCompleta
                    : '${_destinoSeleccionado!.latitude.toStringAsFixed(4)}, '
                      '${_destinoSeleccionado!.longitude.toStringAsFixed(4)}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Distancia calculada: ${_distanciaKm.toStringAsFixed(1)} km',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () {
                  widget.onUbicacionSeleccionada(_distanciaKm, _direccionCompleta);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('CONFIRMAR UBICACION'),
              ),
            ] else ...[
              SizedBox(height: 16),
              Text(
                'Toca en el mapa para seleccionar una ubicacion',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _seleccionarUbicacion(LatLng position) {
    setState(() {
      // Remover marcador anterior de destino si existe
      _markers.removeWhere((marker) => marker.markerId.value == 'destino');
      
      // Agregar nuevo marcador
      _markers.add(
        Marker(
          markerId: MarkerId('destino'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Direccion de Entrega',
            snippet: 'Destino seleccionado',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      
      _destinoSeleccionado = position;
    });
    
    _calcularDistanciaYDireccion(position);
  }

  void _centrarEnUbicacionActual() {
    if (_ubicacionActual != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_ubicacionActual!),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}