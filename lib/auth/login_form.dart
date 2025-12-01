import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showSignUp = false;

  // Campos para registro
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  String _selectedTipo = 'cliente';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: _showSignUp ? _buildSignUpForm() : _buildLoginForm(),
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su correo';
          }
          if (!value.contains('@')) {
            return 'Correo electrónico inválido';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su contraseña';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
      SizedBox(height: 24),
      _isLoading
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'INICIAR SESIÓN',
                style: TextStyle(fontSize: 16),
              ),
            ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _showSignUp = true;
          });
        },
        child: Text(
          '¿No tienes cuenta? Regístrate aquí',
          style: TextStyle(color: Color(0xFF2E7D32)),
        ),
      ),
    ];
  }

  List<Widget> _buildSignUpForm() {
    return [
      TextFormField(
        controller: _nombreController,
        decoration: InputDecoration(
          labelText: 'Nombre completo',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su nombre';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su correo';
          }
          if (!value.contains('@')) {
            return 'Correo electrónico inválido';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _telefonoController,
        decoration: InputDecoration(
          labelText: 'Teléfono',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.phone),
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su teléfono';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _direccionController,
        decoration: InputDecoration(
          labelText: 'Dirección',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.home),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su dirección';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _selectedTipo,
        decoration: InputDecoration(
          labelText: 'Tipo de usuario',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.group),
        ),
        items: [
          DropdownMenuItem(
            value: 'cliente',
            child: Text('Cliente'),
          ),
          DropdownMenuItem(
            value: 'empleado',
            child: Text('Empleado'),
          ),
          DropdownMenuItem(
            value: 'administrador',
            child: Text('Administrador'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedTipo = value!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione un tipo';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su contraseña';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
      SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _showSignUp = false;
                  _clearForm();
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, 50),
                side: BorderSide(color: Color(0xFF2E7D32)),
              ),
              child: Text('CANCELAR'),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      minimumSize: Size(0, 50),
                    ),
                    child: Text('REGISTRARSE'),
                  ),
          ),
        ],
      ),
    ];
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nombreController.clear();
    _telefonoController.clear();
    _direccionController.clear();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión. Verifique sus credenciales.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nombre: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      tipo: _selectedTipo,
    );

    setState(() => _isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar usuario. Intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Registro exitoso! Bienvenido a MobiEvent.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}