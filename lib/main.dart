import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobievent/auth/login_form.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/auth_service.dart';
import 'services/reserva_service.dart';
import 'screens/cliente/inicio_cliente.dart';
import 'screens/empleado/inicio_empleado.dart';
import 'services/geolocation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<ReservaService>(create: (_) => ReservaService()),
        Provider<GeoLocationService>(create: (_) => GeoLocationService()),
        Provider(create: (_) => FirebaseFirestore.instance),
      ],
      child: MaterialApp(
        title: 'MobiEvent - Alquiler Mobiliario',
        theme: ThemeData(
          primaryColor: Color(0xFF2E7D32),
          colorScheme: ColorScheme.light(
            primary: Color(0xFF2E7D32),
            secondary: Color(0xFFFF9800),
          ),
          fontFamily: 'Roboto',
        ),
        home: AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<User?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          if (user.tipo == 'cliente') {
            return InicioCliente();
          } else {
            return InicioEmpleado();
          }
        }
        
        return LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat, size: 80, color: Color(0xFF2E7D32)),
            SizedBox(height: 20),
            Text(
              'MobiEvent',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_seat, size: 60, color: Color(0xFF2E7D32)),
                    SizedBox(height: 20),
                    Text(
                      'Iniciar Sesion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}