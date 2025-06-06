import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/screens/referee_login_screen.dart';
import 'package:aviron_castrais_rugby/screens/referee_matches_screen.dart';
import 'package:aviron_castrais_rugby/services/auth_service.dart';

class RefereeHomeScreen extends StatelessWidget {
  const RefereeHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Afficher directement la page appropriée selon l'état de connexion
    if (AuthService.isLoggedIn) {
      return const RefereeMatchesScreen();
    } else {
      return const RefereeLoginScreen();
    }
  }
}
