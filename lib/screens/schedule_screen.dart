import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/models/schedule.dart';
import 'package:aviron_castrais_rugby/services/tournament_service.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  final Tournament tournament;
  final String? selectedTeamName;

  const ScheduleScreen({Key? key, required this.tournament, this.selectedTeamName}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TournamentService _tournamentService = TournamentService();
  final TextEditingController _searchController = TextEditingController();
  Schedule? _schedule;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  List<String> _allTeams = [];
  List<String> _filteredTeams = [];
  bool _showSuggestions = false;
  String? _selectedTeam;

  @override
  void initState() {
    super.initState();
    if (widget.selectedTeamName != null) {
      _selectedTeam = widget.selectedTeamName;
      _searchController.text = widget.selectedTeamName!;
      _searchQuery = widget.selectedTeamName!;
    }
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final schedule = await _tournamentService.getSchedule(widget.tournament.tournamentId);

      // Extraire toutes les équipes pour les suggestions
      Set<String> teamsSet = {};
      schedule.schedule.values.forEach((games) {
        for (var game in games) {
          teamsSet.add(game.team1.name);
          teamsSet.add(game.team2.name);
        }
      });

      setState(() {
        _schedule = schedule;
        _allTeams = teamsSet.toList()..sort();
        _filteredTeams = _allTeams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTeams(String query) {
    setState(() {
      _searchQuery = query;
      _showSuggestions = query.isNotEmpty;
      _filteredTeams = _allTeams
          .where((team) => team.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectTeam(String teamName) {
    setState(() {
      _selectedTeam = teamName;
      _searchController.text = teamName;
      _searchQuery = teamName;
      _showSuggestions = false;
    });
  }

  void _clearSearch() {
    setState(() {
      _selectedTeam = null;
      _searchController.clear();
      _searchQuery = '';
      _showSuggestions = false;
    });
  }

  List<Game> _getFilteredGames() {
    if (_schedule == null) return [];
    
    List<Game> allGames = [];
    _schedule!.schedule.values.forEach((games) {
      allGames.addAll(games);
    });

    if (_selectedTeam == null || _selectedTeam!.isEmpty) {
      return allGames;
    }

    return allGames.where((game) =>
        game.team1.name.toLowerCase().contains(_selectedTeam!.toLowerCase()) ||
        game.team2.name.toLowerCase().contains(_selectedTeam!.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tournamentService.dispose();
    super.dispose();
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('HH:mm');
      return formatter.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('EEEE d MMMM', 'fr_FR');
      String formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche
        Container(
          padding: const EdgeInsets.all(16),
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
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une équipe...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: _filterTeams,
                onTap: () {
                  if (_searchQuery.isNotEmpty) {
                    setState(() {
                      _showSuggestions = true;
                    });
                  }
                },
              ),
              if (_showSuggestions && _filteredTeams.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredTeams.length > 5 ? 5 : _filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = _filteredTeams[index];
                      return ListTile(
                        title: Text(team),
                        onTap: () => _selectTeam(team),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Contenu principal
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadSchedule,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _schedule == null || _schedule!.schedule.isEmpty
                ? _buildEmptyWidget()
                : _selectedTeam != null
                ? _buildFilteredGamesList()
                : _buildScheduleList(),
          ),
        ),
      ],
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
              onPressed: _loadSchedule,
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
          Icon(Icons.calendar_month, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun match programmé'),
          SizedBox(height: 8),
          Text(
            'Tirez vers le bas pour actualiser',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _schedule!.schedule.keys.length,
      itemBuilder: (context, index) {
        final poolName = _schedule!.schedule.keys.elementAt(index);
        final games = _schedule!.schedule[poolName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
              child: Text(
                poolName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233268),
                ),
              ),
            ),
            ...games.map(_buildGameCard).toList(),
          ],
        );
      },
    );
  }

  Widget _buildGameCard(Game game) {
    // Vérifier si au moins une équipe a un score pour déterminer si le match est terminé
    bool hasResults = game.isCompleted;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec l'heure et le statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(game.startTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasResults ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasResults ? 'Terminé' : 'À venir',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Match
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Équipe 1
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.team1.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${game.team1.score} - ${game.team2.score}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Équipe 2
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        game.team2.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Arbitre et terrain
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Arbitre: ${game.referee}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (game.field != null)
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Terrain ${game.field}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredGamesList() {
    final filteredGames = _getFilteredGames();
    
    if (filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Aucun match trouvé pour "$_selectedTeam"'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Voir tous les matchs'),
            ),
          ],
        ),
      );
    }

    // Grouper les matchs par date
    Map<String, List<Game>> gamesByDate = {};
    for (var game in filteredGames) {
      final dateKey = _formatDate(game.startTime);
      if (!gamesByDate.containsKey(dateKey)) {
        gamesByDate[dateKey] = [];
      }
      gamesByDate[dateKey]!.add(game);
    }

    // Trier les matchs par heure dans chaque date
    gamesByDate.forEach((date, games) {
      games.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    final sortedDates = gamesByDate.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(gamesByDate[a]!.first.startTime);
          final dateB = DateTime.parse(gamesByDate[b]!.first.startTime);
          return dateA.compareTo(dateB);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final games = gamesByDate[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233268),
                ),
              ),
            ),
            ...games.map(_buildGameCard).toList(),
          ],
        );
      },
    );
  }
}
