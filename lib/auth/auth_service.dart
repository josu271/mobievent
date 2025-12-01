import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String nombre;
  final String telefono;
  final String direccion;
  final String tipo;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.tipo,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String userId) {
    return User(
      id: userId,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      direccion: data['direccion'] ?? '',
      tipo: data['tipo'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
      'tipo': tipo,
      'fechaRegistro': DateTime.now(),
    };
  }
}


class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      final userDoc = await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return User.fromFirestore(userDoc.data()!, firebaseUser.uid);
      }
      return null;
    });
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    final userDoc = await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
    if (userDoc.exists) {
      return User.fromFirestore(userDoc.data()!, firebaseUser.uid);
    }
    return null;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userDoc = await _firestore.collection('usuarios').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        return User.fromFirestore(userDoc.data()!, userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      print('Error en signIn: $e');
      return null;
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String direccion,
    required String tipo,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = User(
        id: userCredential.user!.uid,
        email: email,
        nombre: nombre,
        telefono: telefono,
        direccion: direccion,
        tipo: tipo,
      );
      
      await _firestore.collection('usuarios').doc(user.id).set(user.toFirestore());
      
      return user;
    } catch (e) {
      print('Error en signUp: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
  
}