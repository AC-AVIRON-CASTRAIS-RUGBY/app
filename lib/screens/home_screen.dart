import 'package:aviron_castrais_rugby/screens/tournament_detail_screen.dart';
import 'package:aviron_castrais_rugby/services/auth_service.dart';
import 'package:aviron_castrais_rugby/services/tournament_service.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/config/api_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TournamentService _tournamentService = TournamentService();
  List<Tournament> _tournaments = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTournaments();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Supprimer la logique de rechargement automatique qui cause le problème
    // L'utilisateur peut utiliser le pull-to-refresh pour actualiser
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final tournaments = await _tournamentService.getTournaments();

      setState(() {
        _tournaments = tournaments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tournamentService.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Date non disponible';
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR');
      String formatted = formatter.format(date);
      // Première lettre en majuscule
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return 'Date non disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF233268),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('Aviron Castrais', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTournaments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorWidget()
            : _tournaments.isEmpty
            ? _buildEmptyWidget()
            : _buildTournamentsList(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Erreur: $_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTournaments,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_rugby_sharp, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun tournoi disponible'),
          SizedBox(height: 8),
          Text(
            'Tirez vers le bas pour actualiser',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _tournaments.length,
      itemBuilder: (context, index) {
        final tournament = _tournaments[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentDetailScreen(tournament: tournament),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image du tournoi
                AspectRatio(
                  aspectRatio: 16 / 6,
                  child: tournament.image.isNotEmpty 
                    ? Image.network(
                        tournament.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, size: 50),
                                  SizedBox(height: 8),
                                  Text(
                                    "Image non disponible",
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 50),
                              SizedBox(height: 8),
                              Text(
                                "Image non disponible",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),

                // Contenu textuel
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du tournoi
                      Text(
                        tournament.name.isNotEmpty ? tournament.name : 'Tournoi sans nom',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Date du tournoi
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/calendar.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDate(tournament.startDate),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),

                      // Lieu du tournoi
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/map.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tournament.location.isNotEmpty ? tournament.location : 'Lieu non précisé',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}