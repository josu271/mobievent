class Product {
  String id;
  String name;
  String description;
  String category; // 'mesa', 'silla', 'escenario', 'decoracion'
  double pricePerDay;
  int quantity;
  List<String> images;
  
  Product({required this.id, required this.name, required this.description, 
           required this.category, required this.pricePerDay, 
           required this.quantity, required this.images});
  
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
    );
  }
}

class Reservation {
  String id;
  String userId;
  DateTime startDate;
  DateTime endDate;
  String status; // 'pending', 'confirmed', 'preparing', 'delivered', 'completed', 'cancelled'
  List<ReservationItem> items;
  double transportCost;
  double depositAmount;
  double totalAmount;
  String deliveryAddress;
  double deliveryDistance; // en km
  
  Reservation({required this.id, required this.userId, required this.startDate, 
              required this.endDate, required this.status, required this.items,
              required this.transportCost, required this.depositAmount,
              required this.totalAmount, required this.deliveryAddress,
              required this.deliveryDistance});
}

class ReservationItem {
  String productId;
  String productName;
  int quantity;
  double pricePerDay;
  
  ReservationItem({required this.productId, required this.productName,
                   required this.quantity, required this.pricePerDay});
}

class TransportConfig {
  String id;
  double baseCost;
  double costPerKm;
  double minimumDistance;
  
  TransportConfig({required this.id, required this.baseCost,
                   required this.costPerKm, required this.minimumDistance});
}

class Contract {
  String id;
  String reservationId;
  String userId;
  DateTime signedDate;
  String signatureUrl;
  bool isSigned;
  
  Contract({required this.id, required this.reservationId, required this.userId,
            required this.signedDate, required this.signatureUrl,
            required this.isSigned});
}

class WarehouseTask {
  String id;
  String reservationId;
  String employeeId;
  String status; // 'pending', 'preparing', 'ready', 'dispatched'
  DateTime assignedDate;
  List<String> preparedItems;
  
  WarehouseTask({required this.id, required this.reservationId,
                required this.employeeId, required this.status,
                required this.assignedDate, required this.preparedItems});
}