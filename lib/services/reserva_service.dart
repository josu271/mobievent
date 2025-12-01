import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reserva_model.dart';

class ReservaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // RF1: Reserva de inventario por fecha
  Future<List<Reserva>> getReservasPorFecha(DateTime fecha) async {
    try {
      final query = await _firestore
          .collection('reservas')
          .where('fechaInicio', isLessThanOrEqualTo: Timestamp.fromDate(fecha))
          .where('fechaFin', isGreaterThanOrEqualTo: Timestamp.fromDate(fecha))
          .get();

      return query.docs
          .map((doc) => Reserva.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener reservas: $e');
      return [];
    }
  }

  // HU-C1: Ver inventario disponible por fecha
  Future<List<Map<String, dynamic>>> getInventarioDisponible(
      DateTime fecha) async {
    try {
      // Obtener reservas activas para esa fecha
      final reservas = await getReservasPorFecha(fecha);

      // Obtener todos los artículos
      final articulosSnapshot = await _firestore.collection('articulos').get();
      final lotesSnapshot = await _firestore.collection('lotes').get();

      // Calcular disponibilidad
      List<Map<String, dynamic>> inventarioDisponible = [];

      for (var loteDoc in lotesSnapshot.docs) {
        final loteData = loteDoc.data();
        bool disponible = loteData['disponible'] ?? false;

        // Verificar si hay reservas para este lote en la fecha
        for (var reserva in reservas) {
          if (reserva.loteId == loteDoc.id) {
            disponible = false;
            break;
          }
        }

        if (disponible) {
          inventarioDisponible.add({
            'id': loteDoc.id,
            'nombre': loteData['nombre'],
            'descripcion': loteData['descripcion'],
            'tarifaLote': loteData['tarifaLote'],
            'articulos': loteData['articulos'],
          });
        }
      }

      return inventarioDisponible;
    } catch (e) {
      print('Error al obtener inventario: $e');
      return [];
    }
  }

  // HU-C2: Calcular costo de transporte
  Future<double> calcularCostoTransporte(
      double distanciaKm, String tipoArticulo) async {
    try {
      final configSnapshot =
          await _firestore.collection('configuraciones').doc('tarifas').get();
      final configData = configSnapshot.data();

      double tarifaBase = configData?['tarifaPorKm'] ?? 10.0;
      double multiplicador = 1.0;

      // Ajustar por tipo de artículo
      switch (tipoArticulo) {
        case 'escenario':
          multiplicador = 1.5;
          break;
        case 'mesa':
          multiplicador = 1.2;
          break;
        case 'silla':
          multiplicador = 1.0;
          break;
        case 'decoracion':
          multiplicador = 1.3;
          break;
      }

      return distanciaKm * tarifaBase * multiplicador;
    } catch (e) {
      print('Error al calcular transporte: $e');
      return 0.0;
    }
  }

  // RF3: Crear reserva con pago de señal
  Future<String> crearReserva({
    required String clienteId,
    required String loteId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required double costoTotal,
    String? direccionEntrega,
    double? distanciaKm,
  }) async {
    try {
      final reservaRef = _firestore.collection('reservas').doc();

      final reserva = Reserva(
        id: reservaRef.id,
        clienteId: clienteId,
        loteId: loteId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: 'pendiente',
        costoTotal: costoTotal,
        senalPagada: false,
        contratoFirmado: false,
        fechaCreacion: DateTime.now(),
        direccionEntrega: direccionEntrega,
        distanciaKm: distanciaKm,
      );

      await reservaRef.set(reserva.toFirestore());

      // Crear registro de transporte si hay dirección
      if (direccionEntrega != null && distanciaKm != null) {
        final costoTransporte =
            await calcularCostoTransporte(distanciaKm, 'lote');
        await _firestore.collection('transporte').add({
          'reservaId': reservaRef.id,
          'direccionEntrega': direccionEntrega,
          'distanciaKm': distanciaKm,
          'costoTransporte': costoTransporte,
          'vehiculoAsignado': null,
          'estado': 'pendiente',
          'fechaCreacion': Timestamp.now(),
        });
      }

      return reservaRef.id;
    } catch (e) {
      print('Error al crear reserva: $e');
      throw Exception('Error al crear reserva');
    }
  }

  // HU-C4: Reprogramar entrega
  Future<bool> reprogramarEntrega(
      String reservaId, DateTime nuevaFecha) async {
    try {
      final reservaDoc = _firestore.collection('reservas').doc(reservaId);
      final reservaSnapshot = await reservaDoc.get();

      if (!reservaSnapshot.exists) return false;

      final reservaData = reservaSnapshot.data()!;
      final fechaActual = DateTime.now();
      final fechaInicioActual = (reservaData['fechaInicio'] as Timestamp).toDate();

      // Verificar política de reprogramación
      final configSnapshot =
          await _firestore.collection('configuraciones').doc('politicas').get();
      final configData = configSnapshot.data();
      final diasMinimos = configData?['diasMinimosReprogramacion'] ?? 2;

      final diferenciaDias = fechaInicioActual.difference(fechaActual).inDays;

      if (diferenciaDias >= diasMinimos) {
        await reservaDoc.update({
          'fechaInicio': Timestamp.fromDate(nuevaFecha),
          'estado': 'reprogramada',
        });
        return true;
      }

      return false;
    } catch (e) {
      print('Error al reprogramar: $e');
      return false;
    }
  }

  // RF6: Reportes de ocupación
  Future<Map<String, dynamic>> getReporteOcupacion(
      DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final query = await _firestore
          .collection('reservas')
          .where('fechaInicio', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
          .where('fechaInicio', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin))
          .get();

      final reservas = query.docs
          .map((doc) => Reserva.fromFirestore(doc.data(), doc.id))
          .toList();

      // Calcular métricas
      int totalReservas = reservas.length;
      int reservasConfirmadas =
          reservas.where((r) => r.estado == 'confirmada').length;
      int reservasPendientes =
          reservas.where((r) => r.estado == 'pendiente').length;
      double ingresosTotales = reservas.fold(
          0, (sum, reserva) => sum + reserva.costoTotal);

      // Calcular ocupación por día
      Map<String, int> ocupacionPorDia = {};
      for (var reserva in reservas) {
        final dias = reserva.fechaFin.difference(reserva.fechaInicio).inDays + 1;
        for (int i = 0; i < dias; i++) {
          final fecha = reserva.fechaInicio.add(Duration(days: i));
          final clave = '${fecha.year}-${fecha.month}-${fecha.day}';
          ocupacionPorDia[clave] = (ocupacionPorDia[clave] ?? 0) + 1;
        }
      }

      return {
        'totalReservas': totalReservas,
        'reservasConfirmadas': reservasConfirmadas,
        'reservasPendientes': reservasPendientes,
        'ingresosTotales': ingresosTotales,
        'ocupacionPorDia': ocupacionPorDia,
        'periodo': '${fechaInicio.toLocal()} - ${fechaFin.toLocal()}',
      };
    } catch (e) {
      print('Error al generar reporte: $e');
      return {};
    }
  }
}