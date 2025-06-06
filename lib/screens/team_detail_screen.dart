// lib/screens/team_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/models/team.dart';
import 'package:aviron_castrais_rugby/models/player.dart';
import 'package:aviron_castrais_rugby/services/player_service.dart';
import 'package:aviron_castrais_rugby/screens/schedule_screen.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/config/api_config.dart';

class TeamDetailScreen extends StatefulWidget {
  final int tournamentId;
  final Team team;
  final Tournament tournament;

  const TeamDetailScreen({
    Key? key,
    required this.tournamentId,
    required this.team,
    required this.tournament,
  }) : super(key: key);

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final players = await _playerService.getPlayersByTeam(
        widget.tournamentId.toString(),
        widget.team.id.toString(),
      );

      setState(() {
        _players = players;
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
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF233268),
        title: Text(
          widget.team.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlayers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorWidget()
            : _buildTeamDetail(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlayers,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamDetail() {
    return Column(
      children: [
        // En-tête avec le logo et les infos de l'équipe
        _buildTeamHeader(),

        // Liste des joueurs
        Expanded(
          child: _players.isEmpty
              ? _buildEmptyPlayersList()
              : _buildPlayersList(),
        ),
      ],
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo de l'équipe
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: widget.team.logo != null && widget.team.logo!.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    widget.team.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          widget.team.name.isNotEmpty ? widget.team.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Text(
                    widget.team.name.isNotEmpty ? widget.team.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations sur l'équipe
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.team.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catégorie: ${widget.team.ageCategory}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_players.length} joueurs',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bouton pour voir les matchs
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: const Color(0xFF233268),
                        title: Text(
                          'Matchs de ${widget.team.name}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      body: ScheduleScreen(
                        tournament: widget.tournament,
                        selectedTeamName: widget.team.name,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Voir la liste des matchs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF233268),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlayersList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucun joueur disponible pour cette équipe',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tirez vers le bas pour actualiser',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    // Grouper les joueurs par poste
    Map<String, List<Player>> playersByPosition = {};

    for (var player in _players) {
      String position = player.position.isEmpty ? 'Non défini' : player.position;
      if (!playersByPosition.containsKey(position)) {
        playersByPosition[position] = [];
      }
      playersByPosition[position]!.add(player);
    }

    // Trier les joueurs par numéro dans chaque poste
    playersByPosition.forEach((position, players) {
      players.sort((a, b) {
        if (a.number == null && b.number == null) return a.last_name.compareTo(b.last_name);
        if (a.number == null) return 1;
        if (b.number == null) return -1;
        return a.number!.compareTo(b.number!);
      });
    });

    // Définir l'ordre des postes
    List<String> positionOrder = [
      'Pilier', 'Talonneur', 'Seconde ligne', 'Troisième ligne',
      'Demi de mêlée', 'Demi d\'ouverture', 'Centre', 'Ailier', 'Arrière',
      'Non défini' // Ajouter à la fin
    ];

    // Trier les postes selon l'ordre prédéfini ou par ordre alphabétique si le poste n'est pas dans la liste
    List<String> sortedPositions = playersByPosition.keys.toList()
      ..sort((a, b) {
        int indexA = positionOrder.indexOf(a);
        int indexB = positionOrder.indexOf(b);
        if (indexA >= 0 && indexB >= 0) return indexA.compareTo(indexB);
        if (indexA >= 0) return -1;
        if (indexB >= 0) return 1;
        return a.compareTo(b);
      });

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: sortedPositions.length,
      itemBuilder: (context, index) {
        final position = sortedPositions[index];
        final positionPlayers = playersByPosition[position]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
              child: Text(
                position,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233268),
                ),
              ),
            ),
            ...positionPlayers.map(_buildPlayerCard).toList(),
          ],
        );
      },
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Numéro du joueur
            if (player.number != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF233268),
                ),
                child: Center(
                  child: Text(
                    '${player.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Photo du joueur ou initiale
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(left: player.number != null ? 12 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: ClipOval(
                child: Image.network(
                  '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        player.first_name[0] + player.last_name[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 16),

            // Informations du joueur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.first_name + ' ' + player.last_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (player.position.isNotEmpty)
                    Text(
                      player.position,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
