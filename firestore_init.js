// firestore_init.js
// Script para poblar Firestore con datos iniciales
// Ejecutar con: node firestore_init.js

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://unidad-2c48d.firebaseio.com'
});

const db = admin.firestore();

async function crearDatosIniciales() {
  console.log('🏗️  Creando datos iniciales para MobiEvent...');

  try {
    // 1. Crear configuración del sistema
    console.log('📋 Creando configuración del sistema...');
    await crearConfiguracion();
    
    // 2. Crear usuarios de prueba
    console.log('👥 Creando usuarios de prueba...');
    await crearUsuarios();
    
    // 3. Crear artículos de inventario
    console.log('📦 Creando artículos de inventario...');
    await crearArticulos();
    
    // 4. Crear lotes de alquiler
    console.log('🎪 Creando lotes de alquiler...');
    await crearLotes();
    
    // 5. Crear reservas de ejemplo
    console.log('📅 Creando reservas de ejemplo...');
    await crearReservas();
    
    console.log('✅ ¡Datos iniciales creados exitosamente!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error al crear datos:', error);
    process.exit(1);
  }
}

async function crearConfiguracion() {
  const configuraciones = {
    'tarifas': {
      'tarifaPorKm': 10.0,
      'porcentajeSenal': 30,
      'diasMinimosReprogramacion': 2,
      'cargoPorDano': 50.0,
      'actualizado': admin.firestore.FieldValue.serverTimestamp()
    },
    'politicas': {
      'diasMaximoAlquiler': 30,
      'horarioEntrega': '9:00-18:00',
      'horarioRecogida': '9:00-18:00',
      'politicaCancelacion': 'Cancelacion con 48 horas de anticipacion',
      'actualizado': admin.firestore.FieldValue.serverTimestamp()
    },
    'tarifasArticulos': {
      'mesa': 15.0,
      'silla': 5.0,
      'escenario': 50.0,
      'decoracion': 20.0,
      'carpas': 100.0,
      'actualizado': admin.firestore.FieldValue.serverTimestamp()
    },
    'empresa': {
      'nombre': 'MobiEvent S.A.',
      'direccion': 'Av. Principal 123, Lima, Peru',
      'telefono': '+51 123 456 789',
      'email': 'info@mobievent.com',
      'horarioAtencion': 'Lunes a Viernes 8:00-18:00'
    }
  };

  for (const [docId, data] of Object.entries(configuraciones)) {
    await db.collection('configuraciones').doc(docId).set(data);
  }
  console.log('   ✅ Configuración creada');
}

async function crearUsuarios() {
  const usuarios = [
    // Clientes
    {
      email: 'cliente1@test.com',
      nombre: 'Juan Perez',
      telefono: '+51 987 654 321',
      direccion: 'Calle Los Olivos 456, Miraflores, Lima',
      tipo: 'cliente',
      fechaRegistro: admin.firestore.FieldValue.serverTimestamp()
    },
    {
      email: 'cliente2@test.com',
      nombre: 'Maria Lopez',
      telefono: '+51 987 123 456',
      direccion: 'Av. Arequipa 789, San Isidro, Lima',
      tipo: 'cliente',
      fechaRegistro: admin.firestore.FieldValue.serverTimestamp()
    },
    // Empleados
    {
      email: 'empleado@test.com',
      nombre: 'Carlos Rodriguez',
      telefono: '+51 987 789 123',
      direccion: 'Jr. Union 321, Lima Centro',
      tipo: 'empleado',
      fechaRegistro: admin.firestore.FieldValue.serverTimestamp()
    },
    // Administrador
    {
      email: 'admin@test.com',
      nombre: 'Ana Garcia',
      telefono: '+51 987 456 789',
      direccion: 'Av. Javier Prado 654, San Borja',
      tipo: 'administrador',
      fechaRegistro: admin.firestore.FieldValue.serverTimestamp()
    }
  ];

  for (const usuario of usuarios) {
    // Crear usuario en Authentication (solo si existe el proyecto)
    try {
      const userRecord = await admin.auth().createUser({
        email: usuario.email,
        password: 'password123', // Contraseña por defecto
        displayName: usuario.nombre,
        disabled: false
      });

      // Guardar datos adicionales en Firestore
      await db.collection('usuarios').doc(userRecord.uid).set({
        email: usuario.email,
        nombre: usuario.nombre,
        telefono: usuario.telefono,
        direccion: usuario.direccion,
        tipo: usuario.tipo,
        fechaRegistro: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`   ✅ Usuario creado: ${usuario.nombre} (${usuario.tipo})`);
    } catch (error) {
      console.log(`   ⚠️  Usuario ya existe o error: ${usuario.email}`);
    }
  }
}

async function crearArticulos() {
  const articulos = [
    // Mesas
    {
      nombre: 'Mesa Redonda 1.5m',
      descripcion: 'Mesa redonda para 8 personas, diametro 1.5 metros',
      tipo: 'mesa',
      tarifaPorDia: 15.0,
      cantidadTotal: 50,
      cantidadDisponible: 50,
      imagenes: ['https://example.com/mesa1.jpg'],
      caracteristicas: ['Acero inoxidable', 'Resistente al agua', 'Facil de limpiar'],
      estado: 'disponible'
    },
    {
      nombre: 'Mesa Rectangular 2m',
      descripcion: 'Mesa rectangular para 10 personas, 2 metros de largo',
      tipo: 'mesa',
      tarifaPorDia: 18.0,
      cantidadTotal: 30,
      cantidadDisponible: 30,
      imagenes: ['https://example.com/mesa2.jpg'],
      caracteristicas: ['Madera tratada', 'Patas plegables', 'Transporte facil'],
      estado: 'disponible'
    },
    // Sillas
    {
      nombre: 'Silla de Banquete',
      descripcion: 'Silla elegante para eventos formales',
      tipo: 'silla',
      tarifaPorDia: 5.0,
      cantidadTotal: 200,
      cantidadDisponible: 200,
      imagenes: ['https://example.com/silla1.jpg'],
      caracteristicas: ['Tela resistente', 'Estructura metalica', 'Apoyabrazos'],
      estado: 'disponible'
    },
    {
      nombre: 'Silla Plegable Plastica',
      descripcion: 'Silla practica para eventos informales',
      tipo: 'silla',
      tarifaPorDia: 3.0,
      cantidadTotal: 150,
      cantidadDisponible: 150,
      imagenes: ['https://example.com/silla2.jpg'],
      caracteristicas: ['Plastico resistente', 'Plegable', 'Liviana'],
      estado: 'disponible'
    },
    // Escenarios
    {
      nombre: 'Escenario Modular 3x3m',
      descripcion: 'Escenario modular para presentaciones',
      tipo: 'escenario',
      tarifaPorDia: 50.0,
      cantidadTotal: 10,
      cantidadDisponible: 10,
      imagenes: ['https://example.com/escenario1.jpg'],
      caracteristicas: ['Modular', 'Barandas de seguridad', 'Iluminacion integrada'],
      estado: 'disponible'
    },
    {
      nombre: 'Tarima para DJ',
      descripcion: 'Tarima especial para DJs y musica',
      tipo: 'escenario',
      tarifaPorDia: 40.0,
      cantidadTotal: 5,
      cantidadDisponible: 5,
      imagenes: ['https://example.com/escenario2.jpg'],
      caracteristicas: ['Antivibratoria', 'Conexiones electricas', 'Resistente'],
      estado: 'disponible'
    },
    // Decoracion
    {
      nombre: 'Centro de Mesa Floral',
      descripcion: 'Arreglo floral para centro de mesa',
      tipo: 'decoracion',
      tarifaPorDia: 20.0,
      cantidadTotal: 100,
      cantidadDisponible: 100,
      imagenes: ['https://example.com/decoracion1.jpg'],
      caracteristicas: ['Flores artificiales', 'Base estable', 'Reutilizable'],
      estado: 'disponible'
    },
    {
      nombre: 'Cortina de Luces LED',
      descripcion: 'Cortina decorativa con luces LED',
      tipo: 'decoracion',
      tarifaPorDia: 25.0,
      cantidadTotal: 20,
      cantidadDisponible: 20,
      imagenes: ['https://example.com/decoracion2.jpg'],
      caracteristicas: ['LED RGB', 'Control remoto', '10 metros de largo'],
      estado: 'disponible'
    },
    // Carpas
    {
      nombre: 'Carpa 6x6m Blanca',
      descripcion: 'Carpa para eventos al aire libre',
      tipo: 'carpas',
      tarifaPorDia: 100.0,
      cantidadTotal: 8,
      cantidadDisponible: 8,
      imagenes: ['https://example.com/carpa1.jpg'],
      caracteristicas: ['Impermeable', 'Proteccion UV', 'Facil armado'],
      estado: 'disponible'
    }
  ];

  for (const articulo of articulos) {
    await db.collection('articulos').add(articulo);
  }
  console.log(`   ✅ ${articulos.length} artículos creados`);
}

async function crearLotes() {
  // Primero obtener IDs de artículos
  const articulosSnapshot = await db.collection('articulos').limit(5).get();
  const articulosIds = articulosSnapshot.docs.map(doc => doc.id);

  const lotes = [
    {
      nombre: 'Lote Fiesta Basica',
      descripcion: 'Ideal para fiestas pequeñas y familiares',
      articulos: {
        [articulosIds[0]]: 10,  // 10 mesas
        [articulosIds[2]]: 50   // 50 sillas
      },
      tarifaLote: 300.0,
      disponible: true,
      imagenes: ['https://example.com/lote1.jpg'],
      tipoEvento: ['familiar', 'pequeno'],
      capacidad: '50 personas'
    },
    {
      nombre: 'Lote Bodas Elegante',
      descripcion: 'Perfecto para bodas y eventos formales',
      articulos: {
        [articulosIds[1]]: 20,  // 20 mesas rectangulares
        [articulosIds[3]]: 100, // 100 sillas de banquete
        [articulosIds[4]]: 1,   // 1 escenario
        [articulosIds[6]]: 30   // 30 centros de mesa
      },
      tarifaLote: 800.0,
      disponible: true,
      imagenes: ['https://example.com/lote2.jpg'],
      tipoEvento: ['boda', 'formal', 'grande'],
      capacidad: '120 personas'
    },
    {
      nombre: 'Lote Corporativo',
      descripcion: 'Para eventos empresariales y conferencias',
      articulos: {
        [articulosIds[0]]: 15,
        [articulosIds[2]]: 75,
        [articulosIds[4]]: 1,
        [articulosIds[5]]: 1
      },
      tarifaLote: 650.0,
      disponible: true,
      imagenes: ['https://example.com/lote3.jpg'],
      tipoEvento: ['corporativo', 'conferencia'],
      capacidad: '75 personas'
    },
    {
      nombre: 'Lote Fiesta Infantil',
      descripcion: 'Divertido y colorido para fiestas infantiles',
      articulos: {
        [articulosIds[0]]: 5,
        [articulosIds[3]]: 30,
        [articulosIds[6]]: 10,
        [articulosIds[7]]: 2
      },
      tarifaLote: 250.0,
      disponible: true,
      imagenes: ['https://example.com/lote4.jpg'],
      tipoEvento: ['infantil', 'colorido', 'pequeno'],
      capacidad: '30 niños'
    }
  ];

  for (const lote of lotes) {
    await db.collection('lotes').add(lote);
  }
  console.log(`   ✅ ${lotes.length} lotes creados`);
}

async function crearReservas() {
  // Obtener IDs de usuarios y lotes
  const usuariosSnapshot = await db.collection('usuarios').where('tipo', '==', 'cliente').limit(2).get();
  const lotesSnapshot = await db.collection('lotes').limit(2).get();

  if (usuariosSnapshot.empty || lotesSnapshot.empty) {
    console.log('   ⚠️  No hay usuarios o lotes para crear reservas');
    return;
  }

  const clienteId = usuariosSnapshot.docs[0].id;
  const loteId = lotesSnapshot.docs[0].id;

  const fechaHoy = new Date();
  const fechaInicio = new Date(fechaHoy);
  fechaInicio.setDate(fechaHoy.getDate() + 7); // Reserva para la próxima semana
  
  const fechaFin = new Date(fechaInicio);
  fechaFin.setDate(fechaInicio.getDate() + 2); // 2 días de alquiler

  const reservas = [
    {
      clienteId: clienteId,
      loteId: loteId,
      fechaInicio: admin.firestore.Timestamp.fromDate(fechaInicio),
      fechaFin: admin.firestore.Timestamp.fromDate(fechaFin),
      estado: 'confirmada',
      costoTotal: 650.0,
      senalPagada: true,
      contratoFirmado: true,
      direccionEntrega: 'Av. Salaverry 1234, Jesus Maria, Lima',
      distanciaKm: 12.5,
      costoTransporte: 125.0,
      fechaCreacion: admin.firestore.FieldValue.serverTimestamp(),
      notas: 'Entrega en el salon de eventos "Los Jardines"',
      contactoEntrega: '+51 987 654 321',
      horarioEntrega: '14:00'
    },
    {
      clienteId: clienteId,
      loteId: lotesSnapshot.docs[1].id,
      fechaInicio: admin.firestore.Timestamp.fromDate(
        new Date(fechaHoy.getFullYear(), fechaHoy.getMonth(), fechaHoy.getDate() + 14)
      ),
      fechaFin: admin.firestore.Timestamp.fromDate(
        new Date(fechaHoy.getFullYear(), fechaHoy.getMonth(), fechaHoy.getDate() + 16)
      ),
      estado: 'pendiente',
      costoTotal: 800.0,
      senalPagada: false,
      contratoFirmado: false,
      fechaCreacion: admin.firestore.FieldValue.serverTimestamp(),
      notas: 'Por confirmar direccion exacta'
    }
  ];

  for (const reserva of reservas) {
    const reservaRef = await db.collection('reservas').add(reserva);
    
    // Crear registro de transporte si aplica
    if (reserva.direccionEntrega && reserva.costoTransporte) {
      await db.collection('transporte').add({
        reservaId: reservaRef.id,
        direccionEntrega: reserva.direccionEntrega,
        distanciaKm: reserva.distanciaKm,
        costoTransporte: reserva.costoTransporte,
        vehiculoAsignado: null,
        estado: 'pendiente',
        fechaCreacion: admin.firestore.FieldValue.serverTimestamp(),
        fechaEntregaEstimada: reserva.fechaInicio,
        contactoEntrega: reserva.contactoEntrega
      });
    }
  }

  console.log(`   ✅ ${reservas.length} reservas creadas`);
}

// Ejecutar script
crearDatosIniciales();