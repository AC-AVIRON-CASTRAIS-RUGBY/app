import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/screens/referee_login_screen.dart';
import 'package:aviron_castrais_rugby/screens/referee_matches_screen.dart';
import 'package:aviron_castrais_rugby/services/auth_service.dart';

class RefereeHomeScreen extends StatefulWidget {
  const RefereeHomeScreen({Key? key}) : super(key: key);

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Afficher la page appropriée selon l'état de connexion
    if (AuthService.isLoggedIn) {
      return const RefereeMatchesScreen();
    } else {
      return const RefereeLoginScreen();
    }
  }
}
