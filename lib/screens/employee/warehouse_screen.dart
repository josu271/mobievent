import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class WarehouseScreen extends StatefulWidget {
  @override
  _WarehouseScreenState createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Panel de Almacén')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('warehouse_tasks')
            .orderBy('assignedDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          final tasks = snapshot.data?.docs ?? [];
          
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>;
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _getStatusIcon(data['status']),
                  title: Text('Reserva: ${data['reservationId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado: ${data['status']}'),
                      Text('Asignado: ${_formatDate(data['assignedDate'])}'),
                      Text('Items: ${(data['preparedItems'] as List).length}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () => _updateTaskStatus(task.id, data['status']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icon(Icons.access_time, color: Colors.orange);
      case 'preparing':
        return Icon(Icons.build, color: Colors.blue);
      case 'ready':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'dispatched':
        return Icon(Icons.local_shipping, color: Colors.purple);
      default:
        return Icon(Icons.help, color: Colors.grey);
    }
  }
  
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    }
    return 'Fecha no disponible';
  }
  
  Future<void> _updateTaskStatus(String taskId, String currentStatus) async {
    String newStatus;
    
    switch (currentStatus) {
      case 'pending':
        newStatus = 'preparing';
        break;
      case 'preparing':
        newStatus = 'ready';
        break;
      case 'ready':
        newStatus = 'dispatched';
        break;
      default:
        return;
    }
    
    await FirebaseFirestore.instance
        .collection('warehouse_tasks')
        .doc(taskId)
        .update({'status': newStatus});
  }
}