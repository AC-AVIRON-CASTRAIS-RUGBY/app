// lib/screens/team_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/models/team.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/models/player.dart';
import 'package:aviron_castrais_rugby/models/category.dart';
import 'package:aviron_castrais_rugby/services/player_service.dart';
import 'package:aviron_castrais_rugby/services/category_service.dart';
import 'package:aviron_castrais_rugby/screens/tournament_detail_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;
  final Tournament tournament;
  final int tournamentId;

  const TeamDetailScreen({
    Key? key,
    required this.team,
    required this.tournament,
    required this.tournamentId,
  }) : super(key: key);

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final PlayerService _playerService = PlayerService();
  final CategoryService _categoryService = CategoryService();
  List<Player> _players = [];
  Category? _category;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Charger les joueurs et la catégorie en parallèle
      final results = await Future.wait([
        _playerService.getPlayersByTeam(widget.tournamentId, widget.team.id),
        _categoryService.getCategoryById(widget.tournamentId, widget.team.categoryId),
      ]);

      final players = results[0] as List<Player>;
      final category = results[1] as Category;

      setState(() {
        _players = players;
        _category = category;
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
    _categoryService.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {
              // Naviguer vers l'onglet calendrier du TournamentDetailScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentDetailScreen(
                    tournament: widget.tournament,
                    initialTabIndex: 3, // Index de l'onglet Calendrier
                    selectedTeamName: widget.team.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorWidget()
            : _buildContent(),
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
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamHeader(),
          const SizedBox(height: 16),
          _buildPlayersSection(),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF233268),
            const Color(0xFF233268).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo de l'équipe
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: widget.team.logo != null && widget.team.logo!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.team.logo!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              widget.team.name.isNotEmpty 
                                  ? widget.team.name[0].toUpperCase() 
                                  : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF233268),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        widget.team.name.isNotEmpty 
                            ? widget.team.name[0].toUpperCase() 
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF233268),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catégorie: ${_category?.name.toUpperCase() ?? 'Non spécifiée'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_players.length} joueur${_players.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_category != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_category!.gameDuration != null)
                    _buildCategoryInfo('Durée match', '${_category!.gameDuration} min'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Effectif',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233268),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF233268),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_players.length} joueur${_players.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_players.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.group_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aucun joueur enregistré',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'L\'effectif de cette équipe n\'a pas encore été saisi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return _buildPlayerCard(player, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Numéro du joueur
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF233268),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    player.number?.toString() ?? (index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                      '${player.first_name} ${player.last_name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.position,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge de position
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPositionColor(player.position),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPositionAbbreviation(player.position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(String position) {
    switch (position.toLowerCase()) {
      case 'ailier':
        return Colors.green;
      case 'centre':
        return Colors.blue;
      case 'demi':
        return Colors.orange;
      case 'avant':
        return Colors.red;
      case 'arrière':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getPositionAbbreviation(String position) {
    switch (position.toLowerCase()) {
      case 'ailier':
        return 'AIL';
      case 'centre':
        return 'CTR';
      case 'demi':
        return 'DMI';
      case 'avant':
        return 'AVT';
      case 'arrière':
        return 'ARR';
      default:
        return 'JOU';
    }
  }
}
