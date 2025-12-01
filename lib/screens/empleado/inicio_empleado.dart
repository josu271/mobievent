import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_service.dart';
import 'almacen_screen.dart';
import 'admin/configuracion_screen.dart';
import 'logistica/logistica_screen.dart';

class InicioEmpleado extends StatefulWidget {
  @override
  _InicioEmpleadoState createState() => _InicioEmpleadoState();
}

class _InicioEmpleadoState extends State<InicioEmpleado> {
  int _selectedIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MobiEvent - ${_currentUser?.tipo?.toUpperCase() ?? "Empleado"}'),
        backgroundColor: Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: _buildBody(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBody() {
    if (_currentUser == null) {
      return Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return DashboardEmpleadoScreen();
      case 1:
        return AlmacenScreen();
      case 2:
        return LogisticaScreen();
      case 3:
        return ConfiguracionScreen();
      default:
        return DashboardEmpleadoScreen();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _currentUser?.nombre ?? 'Empleado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentUser?.email ?? '',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            title: 'Almacén',
            index: 1,
          ),
          if (_currentUser?.tipo == 'administrador' || _currentUser?.tipo == 'empleado')
            _buildDrawerItem(
              icon: Icons.local_shipping,
              title: 'Logística',
              index: 2,
            ),
          if (_currentUser?.tipo == 'administrador')
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Configuración',
              index: 3,
            ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index ? Color(0xFF2E7D32) : Colors.grey),
      title: Text(title,
          style: TextStyle(
              color: _selectedIndex == index ? Color(0xFF2E7D32) : Colors.black)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

class DashboardEmpleadoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen rápido
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Reservas Hoy',
                  '5',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En Preparación',
                  '3',
                  Icons.inventory,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Entregas Pend.',
                  '2',
                  Icons.local_shipping,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Items Disp.',
                  '85%',
                  Icons.warehouse,
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Acciones rápidas
          Text(
            'Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                'Preparar Pedido',
                Icons.inventory,
                Color(0xFF2E7D32),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AlmacenScreen()),
                  );
                },
              ),
              _buildActionCard(
                'Asignar Transporte',
                Icons.local_shipping,
                Color(0xFFFF9800),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogisticaScreen()),
                  );
                },
              ),
              _buildActionCard(
                'Ver Inventario',
                Icons.warehouse,
                Colors.blue,
                () {
                  // Navegar a inventario
                },
              ),
              _buildActionCard(
                'Clientes Nuevos',
                Icons.person_add,
                Colors.purple,
                () {
                  // Ver clientes nuevos
                },
              ),
            ],
          ),

          SizedBox(height: 24),

          // Reservas recientes
          Text(
            'Reservas Recientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildReservasRecientes(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservasRecientes() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('reservas')
          .orderBy('fechaCreacion', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay reservas recientes'),
            ),
          );
        }

        final reservas = snapshot.data!.docs;

        return Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final reserva = reservas[index];
              final data = reserva.data() as Map<String, dynamic>;
              final fecha = (data['fechaCreacion'] as Timestamp).toDate();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getEstadoColor(data['estado']),
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Reserva #${reserva.id.substring(0, 8)}'),
                subtitle: Text('${_formatDate(fecha)} - \$${data['costoTotal']}'),
                trailing: Chip(
                  label: Text(
                    data['estado'],
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: _getEstadoColor(data['estado']),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'confirmada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'en_preparacion':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}