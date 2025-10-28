import 'package:flutter/material.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pantalla de perfil simple (placeholder, editable más adelante)
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            const Text('Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('usuario@ejemplo.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text('Funciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mis favoritos'),
              onTap: () {
                Navigator.of(context).pushNamed('/favoritos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de actividad'),
              onTap: () {},
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // cerrar sesión
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('Cerrar sesión'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

