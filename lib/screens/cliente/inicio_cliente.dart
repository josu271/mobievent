import 'package:flutter/material.dart';
import 'package:mobievent/services/reserva_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_service.dart';
import 'reserva_screen.dart';
import 'pago_screen.dart';
import 'mapa_screen.dart';

class InicioCliente extends StatefulWidget {
  @override
  _InicioClienteState createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
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

  final List<Widget> _screens = [
    HomeScreenCliente(),
    ReservasClienteScreen(),
    PerfilClienteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MobiEvent - Cliente'),
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Mis Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeScreenCliente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de bienvenida
          Card(
            color: Color(0xFF2E7D32),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Alquila mobiliario para tu evento!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mesas, sillas, escenarios y decoracion para cualquier ocasion',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservaScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9800),
                    ),
                    child: Text('RESERVAR AHORA'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Categorias
          Text(
            'Categorias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryCard(Icons.table_restaurant, 'Mesas', '50+ modelos'),
                _buildCategoryCard(Icons.chair, 'Sillas', '200+ unidades'),
                _buildCategoryCard(Icons.event, 'Escenarios', '10+ disenos'),
                _buildCategoryCard(Icons.celebration, 'Decoracion', '30+ opciones'),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Promociones
          Text(
            'Promociones Especiales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.red, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '15% de descuento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('En alquileres de mas de 3 dias'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Como funciona
          Text(
            'Como funciona',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildStep(
            '1. Selecciona fecha',
            'Elige la fecha de tu evento y el mobiliario',
            Icons.calendar_today,
          ),
          _buildStep(
            '2. Calcula transporte',
            'Ingresa tu direccion para calcular el costo',
            Icons.map,
          ),
          _buildStep(
            '3. Paga la senal',
            'Confirma con el 30% del total',
            Icons.payment,
          ),
          _buildStep(
            '4. ¡Disfruta tu evento!',
            'Nosotros nos encargamos del resto',
            Icons.celebration,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle) {
    return Card(
      margin: EdgeInsets.only(right: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Color(0xFF2E7D32)),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF2E7D32)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}

class ReservasClienteScreen extends StatefulWidget {
  @override
  _ReservasClienteScreenState createState() => _ReservasClienteScreenState();
}

class _ReservasClienteScreenState extends State<ReservasClienteScreen> {
  Future<User?> _getCurrentUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final currentUser = userSnapshot.data;
        if (currentUser == null) {
          return Center(child: Text('Usuario no encontrado'));
        }

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('reservas')
              .where('clienteId', isEqualTo: currentUser.id)
              .orderBy('fechaCreacion', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No tienes reservas aun',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReservaScreen()),
                        );
                      },
                      child: Text('Hacer mi primera reserva'),
                    ),
                  ],
                ),
              );
            }

            final reservas = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                final data = reserva.data() as Map<String, dynamic>;
                final fechaInicio = (data['fechaInicio'] as Timestamp).toDate();
                final fechaFin = (data['fechaFin'] as Timestamp).toDate();

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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(
                                data['estado'].toUpperCase(),
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
                            Text('${_formatDate(fechaInicio)} - ${_formatDate(fechaFin)}'),
                          ],
                        ),
                        SizedBox(height: 8),
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
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              data['senalPagada'] ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: data['senalPagada'] ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(data['senalPagada'] ? 'Senal pagada' : 'Senal pendiente'),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            if (data['estado'] == 'confirmada')
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _mostrarReprogramarDialog(reserva.id, fechaInicio);
                                  },
                                  child: Text('REPROGRAMAR'),
                                ),
                              ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PagoScreen(reservaId: reserva.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF9800),
                                ),
                                child: Text('DETALLES'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'en_preparacion':
        return Colors.blue;
      case 'entregada':
        return Colors.purple;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _mostrarReprogramarDialog(String reservaId, DateTime fechaActual) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime nuevaFecha = fechaActual;
        return AlertDialog(
          title: Text('Reprogramar entrega'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selecciona la nueva fecha de entrega:'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: fechaActual,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    nuevaFecha = picked;
                  }
                },
                child: Text('SELECCIONAR FECHA'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reservaService = ReservaService();
                final exitoso = await reservaService.reprogramarEntrega(reservaId, nuevaFecha);
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(exitoso 
                      ? '¡Entrega reprogramada exitosamente!'
                      : 'No se puede reprogramar. Verifica el plazo minimo.'),
                    backgroundColor: exitoso ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text('CONFIRMAR'),
            ),
          ],
        );
      },
    );
  }
}

class PerfilClienteScreen extends StatefulWidget {
  @override
  _PerfilClienteScreenState createState() => _PerfilClienteScreenState();
}

class _PerfilClienteScreenState extends State<PerfilClienteScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return Center(child: Text('Usuario no encontrado'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Tarjeta de perfil
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF2E7D32),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.nombre,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Chip(
                        label: Text(
                          'CLIENTE',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Informacion de contacto
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informacion de contacto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoItem(Icons.phone, 'Telefono', user.telefono),
                      _buildInfoItem(Icons.home, 'Direccion', user.direccion),
                      _buildInfoItem(Icons.email, 'Correo', user.email),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Acciones
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildActionButton(
                        'Editar perfil',
                        Icons.edit,
                        () {
                          _mostrarEditarPerfilDialog(user);
                        },
                      ),
                      _buildActionButton(
                        'Cambiar contrasena',
                        Icons.lock,
                        () {
                          // Implementar cambio de contrasena
                        },
                      ),
                      _buildActionButton(
                        'Politicas de alquiler',
                        Icons.description,
                        () {
                          // Mostrar politicas
                        },
                      ),
                      _buildActionButton(
                        'Cerrar sesion',
                        Icons.logout,
                        () {
                          authService.signOut();
                        },
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2E7D32)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Color(0xFF2E7D32)),
      title: Text(text,
          style: TextStyle(color: isLogout ? Colors.red : Colors.black)),
      trailing: Icon(Icons.chevron_right),
      onTap: onPressed,
    );
  }

  void _mostrarEditarPerfilDialog(User user) {
    // Implementar dialogo para editar perfil
  }
}