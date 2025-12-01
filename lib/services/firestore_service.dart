import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // HU-C1: Ver inventario disponible por fecha
  Stream<List<Product>> getAvailableProducts(DateTime date) {
    return _db.collection('products')
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList());
  }
  
  // RF1: Reserva de inventario por fecha
  Future<String> createReservation(Reservation reservation) async {
    final docRef = await _db.collection('reservations').add({
      'userId': reservation.userId,
      'startDate': reservation.startDate,
      'endDate': reservation.endDate,
      'status': reservation.status,
      'items': reservation.items.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'pricePerDay': item.pricePerDay,
      }).toList(),
      'transportCost': reservation.transportCost,
      'depositAmount': reservation.depositAmount,
      'totalAmount': reservation.totalAmount,
      'deliveryAddress': reservation.deliveryAddress,
      'deliveryDistance': reservation.deliveryDistance,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
  
  // HU-C2: Cálculo de transporte por distancia (RF2)
  Future<double> calculateTransportCost(double distance) async {
    final snapshot = await _db.collection('transport_config').doc('pricing').get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final baseCost = data['baseCost'] ?? 0.0;
      final costPerKm = data['costPerKm'] ?? 0.0;
      final minimumDistance = data['minimumDistance'] ?? 5.0;
      
      final effectiveDistance = distance < minimumDistance ? minimumDistance : distance;
      return baseCost + (effectiveDistance * costPerKm);
    }
    return 0.0;
  }
  
  // HU-C3: Pagar señal y firmar contrato (RF3)
  Future<void> createContract(Contract contract) async {
    await _db.collection('contracts').doc(contract.id).set({
      'reservationId': contract.reservationId,
      'userId': contract.userId,
      'signedDate': contract.signedDate,
      'signatureUrl': contract.signatureUrl,
      'isSigned': contract.isSigned,
    });
  }
  
  // HU-C4: Reprogramar entrega (RF5)
  Future<bool> rescheduleDelivery(String reservationId, DateTime newDate) async {
    final reservationDoc = await _db.collection('reservations').doc(reservationId).get();
    if (reservationDoc.exists) {
      final reservation = reservationDoc.data()!;
      final currentDate = DateTime.now();
      final originalDate = (reservation['startDate'] as Timestamp).toDate();
      
      // Verificar si está dentro del plazo permitido (ej: 48 horas antes)
      final hoursDifference = originalDate.difference(currentDate).inHours;
      
      if (hoursDifference >= 48) {
        await _db.collection('reservations').doc(reservationId).update({
          'startDate': newDate,
          'status': 'rescheduled',
        });
        return true;
      }
    }
    return false;
  }
  
  // HU-E1: Almacén - bloquear items y preparar despacho (RF4)
  Future<void> createWarehouseTask(WarehouseTask task) async {
    await _db.collection('warehouse_tasks').doc(task.id).set({
      'reservationId': task.reservationId,
      'employeeId': task.employeeId,
      'status': task.status,
      'assignedDate': task.assignedDate,
      'preparedItems': task.preparedItems,
    });
    
    // Bloquear items del inventario
    for (var item in task.preparedItems) {
      await _db.collection('products').doc(item).update({
        'blockedForReservation': task.reservationId,
      });
    }
  }
  
  // HU-E2: Logística - asignar rutas y vehículos
  Future<void> assignRoute(String taskId, String vehicleId, String driverId, List<String> routePoints) async {
    await _db.collection('routes').doc(taskId).set({
      'warehouseTaskId': taskId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'routePoints': routePoints,
      'assignedAt': FieldValue.serverTimestamp(),
      'status': 'assigned',
    });
  }
  
  // HU-E3: Admin - configurar tarifas
  Future<void> updateTransportPricing(double baseCost, double costPerKm, double minimumDistance) async {
    await _db.collection('transport_config').doc('pricing').set({
      'baseCost': baseCost,
      'costPerKm': costPerKm,
      'minimumDistance': minimumDistance,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // HU-E4: Ver estado de inventario y días ocupados (RF6)
  Stream<QuerySnapshot> getInventoryStatus() {
    return _db.collection('products')
        .orderBy('category')
        .snapshots();
  }
  
  Future<List<DateTime>> getOccupiedDays(String productId) async {
    final snapshot = await _db.collection('reservations')
        .where('items', arrayContainsAny: [productId])
        .where('status', whereIn: ['confirmed', 'preparing', 'delivered'])
        .get();
    
    final occupiedDays = <DateTime>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final start = (data['startDate'] as Timestamp).toDate();
      final end = (data['endDate'] as Timestamp).toDate();
      
      for (var day = start; day.isBefore(end) || day.isAtSameMomentAs(end); day = day.add(Duration(days: 1))) {
        occupiedDays.add(day);
      }
    }
    return occupiedDays;
  }
}