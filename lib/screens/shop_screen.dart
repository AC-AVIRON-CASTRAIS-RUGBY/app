import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final VoidCallback? onNavigateToTournaments;

  const ShopScreen({Key? key, this.onNavigateToTournaments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF233268),
        title: const Text(
          'Boutique',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: onNavigateToTournaments,
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 80,
              color: Color(0xFF233268),
            ),
            SizedBox(height: 20),
            Text(
              'Boutique',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233268),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'La boutique sera bientôt disponible !',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Glissez vers la droite pour revenir aux tournois',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
