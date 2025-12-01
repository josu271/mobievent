import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  String id;
  String clienteId;
  String loteId;
  DateTime fechaInicio;
  DateTime fechaFin;
  String estado;
  double costoTotal;
  bool senalPagada;
  bool contratoFirmado;
  DateTime fechaCreacion;
  String? direccionEntrega;
  double? distanciaKm;
  double? costoTransporte;

  Reserva({
    required this.id,
    required this.clienteId,
    required this.loteId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.costoTotal,
    required this.senalPagada,
    required this.contratoFirmado,
    required this.fechaCreacion,
    this.direccionEntrega,
    this.distanciaKm,
    this.costoTransporte,
  });

  factory Reserva.fromFirestore(Map<String, dynamic> data, String docId) {
    return Reserva(
      id: docId,
      clienteId: data['clienteId'],
      loteId: data['loteId'],
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp).toDate(),
      estado: data['estado'],
      costoTotal: data['costoTotal'].toDouble(),
      senalPagada: data['senalPagada'],
      contratoFirmado: data['contratoFirmado'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      direccionEntrega: data['direccionEntrega'],
      distanciaKm: data['distanciaKm']?.toDouble(),
      costoTransporte: data['costoTransporte']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clienteId': clienteId,
      'loteId': loteId,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'estado': estado,
      'costoTotal': costoTotal,
      'senalPagada': senalPagada,
      'contratoFirmado': contratoFirmado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'direccionEntrega': direccionEntrega,
      'distanciaKm': distanciaKm,
      'costoTransporte': costoTransporte,
    };
  }
}