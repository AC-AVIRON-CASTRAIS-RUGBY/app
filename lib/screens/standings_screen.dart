import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/models/standings.dart';
import 'package:aviron_castrais_rugby/services/tournament_service.dart';
import 'dart:async';

class StandingsScreen extends StatefulWidget {
  final Tournament tournament;

  const StandingsScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  final TournamentService _tournamentService = TournamentService();
  List<TeamStanding> _standings = [];
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStandings();
    // Actualisation automatique toutes les 30 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _loadStandings();
    });
  }

  Future<void> _loadStandings() async {
    try {
      if (!mounted) return; // Vérifier si le widget est encore monté
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final standings = await _tournamentService.getStandings(widget.tournament.tournamentId);

      if (!mounted) return; // Vérifier à nouveau avant setState
      
      setState(() {
        _standings = standings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Vérifier avant setState en cas d'erreur
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tournamentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStandings,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _standings.isEmpty
          ? _buildEmptyWidget()
          : _buildStandingsTable(),
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
              onPressed: _loadStandings,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun classement disponible'),
          SizedBox(height: 8),
          Text(
            'Les classements apparaîtront après les premiers matchs',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Tirez vers le bas pour actualiser',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTable() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Podium pour le top 3
          if (_standings.length >= 3) _buildPodium(),
          
          const SizedBox(height: 20),
          
          // Liste complète des équipes
          ..._standings.asMap().entries.map((entry) {
            final index = entry.key;
            final standing = entry.value;
            return _buildTeamCard(standing, index);
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Légende
          _buildLegendCard(),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _standings.take(3).toList();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2ème place
                if (top3.length > 1) _buildPodiumPosition(top3[1], 2, 80),
                
                // 1ère place
                _buildPodiumPosition(top3[0], 1, 100),
                
                // 3ème place
                if (top3.length > 2) _buildPodiumPosition(top3[2], 3, 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumPosition(TeamStanding standing, int position, double height) {
    Color positionColor;
    String medal;
    
    switch (position) {
      case 1:
        positionColor = Colors.amber;
        medal = '🥇';
        break;
      case 2:
        positionColor = Colors.grey[400]!;
        medal = '🥈';
        break;
      case 3:
        positionColor = Colors.brown[400]!;
        medal = '🥉';
        break;
      default:
        positionColor = Colors.blue;
        medal = '🏅';
    }

    return Column(
      children: [
        // Médaille et nom
        Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(medal, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                standing.teamName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF233268),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${standing.points} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Podium
        Container(
          width: 60,
          height: height,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: positionColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(TeamStanding standing, int index) {
    final isTopThree = standing.rank <= 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: isTopThree
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      _getPositionColor(standing.rank).withOpacity(0.1),
                      Colors.white,
                    ],
                  )
                : null,
            color: isTopThree ? null : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Position badge
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: _getPositionColor(standing.rank),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${standing.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Team info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team name
                      Text(
                        standing.teamName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Stats row
                      Row(
                        children: [
                          _buildMiniStat('MJ', standing.matchesPlayed, Colors.grey[600]!),
                          const SizedBox(width: 16),
                          _buildMiniStat('V', standing.wins, Colors.green),
                          const SizedBox(width: 16),
                          _buildMiniStat('N', standing.draws, Colors.orange),
                          const SizedBox(width: 16),
                          _buildMiniStat('D', standing.losses, Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Points section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF233268),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'POINTS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${standing.points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF233268)),
                SizedBox(width: 8),
                Text(
                  'Légende',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF233268),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('MJ', 'Matchs Joués', Colors.blue),
                _buildLegendItem('V', 'Victoires', Colors.green),
                _buildLegendItem('N', 'Nuls', Colors.orange),
                _buildLegendItem('D', 'Défaites', Colors.red),
                _buildLegendItem('PTS', 'Points', const Color(0xFF233268)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String abbr, String full, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            abbr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          full,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber; // Or
      case 2:
        return Colors.grey[400]!; // Argent
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return const Color(0xFF233268);
    }
  }

  String _getPositionText(int position) {
    switch (position) {
      case 1:
        return '🥇 Champion';
      case 2:
        return '🥈 Vice-champion';
      case 3:
        return '🥉 3ème place';
      default:
        return '';
    }
  }
}
