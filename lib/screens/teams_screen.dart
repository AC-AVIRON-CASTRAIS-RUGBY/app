import 'package:aviron_castrais_rugby/screens/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/models/team.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/models/category.dart';
import 'package:aviron_castrais_rugby/services/team_service.dart';
import 'package:aviron_castrais_rugby/services/category_service.dart';

class TeamsScreen extends StatefulWidget {
  final Tournament tournament;

  const TeamsScreen({
    Key? key,
    required this.tournament,
  }) : super(key: key);

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TeamService _teamService = TeamService();
  final CategoryService _categoryService = CategoryService();
  List<Team> _teams = [];
  List<Team> _filteredTeams = [];
  List<Category> _categories = [];
  Map<int, String> _categoryNames = {};
  String? _selectedCategoryName;
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

      // Charger les équipes et catégories en parallèle
      final results = await Future.wait([
        _teamService.getTeamsByTournament(widget.tournament.tournamentId),
        _categoryService.getCategoriesByTournament(widget.tournament.tournamentId),
      ]);

      final teams = results[0] as List<Team>;
      final categories = results[1] as List<Category>;

      // Créer un map des noms de catégories par ID
      final categoryNames = <int, String>{};
      for (var category in categories) {
        categoryNames[category.categoryId] = category.name.toUpperCase();
      }

      setState(() {
        _teams = teams;
        _filteredTeams = teams;
        _categories = categories;
        _categoryNames = categoryNames;
        _selectedCategoryName = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String? categoryName) {
    setState(() {
      _selectedCategoryName = categoryName;
      if (categoryName == null) {
        _filteredTeams = _teams;
      } else {
        _filteredTeams = _teams.where((team) {
          final teamCategoryName = _categoryNames[team.categoryId] ?? 'Non spécifié';
          return teamCategoryName == categoryName;
        }).toList();
      }
      _filteredTeams.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    });
  }

  @override
  void dispose() {
    _teamService.dispose();
    _categoryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isLoading && _error == null && _teams.isNotEmpty)
          _buildCategoryFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _filteredTeams.isEmpty
                ? _buildEmptyWidget()
                : _buildTeamsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final availableCategoryNames = _teams
        .map((team) => _categoryNames[team.categoryId] ?? 'Non spécifié')
        .toSet()
        .toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrer par catégorie :',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(null, 'Toutes'),
                ...availableCategoryNames.map((categoryName) => 
                  _buildCategoryChip(categoryName, categoryName)),
              ],
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? categoryName, String label) {
    final isSelected = _selectedCategoryName == categoryName;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF233268).withOpacity(0.2),
        checkmarkColor: const Color(0xFF233268),
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF233268) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => _filterByCategory(categoryName),
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
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedCategoryName == null
                ? 'Aucune équipe inscrite à ce tournoi'
                : 'Aucune équipe dans la catégorie $_selectedCategoryName',
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

  Widget _buildTeamsList() {
    // Regrouper les équipes par nom de catégorie
    Map<String, List<Team>> teamsByCategory = {};

    for (var team in _filteredTeams) {
      final categoryName = _categoryNames[team.categoryId] ?? 'Non spécifié';
      if (!teamsByCategory.containsKey(categoryName)) {
        teamsByCategory[categoryName] = [];
      }
      teamsByCategory[categoryName]!.add(team);
    }

    teamsByCategory.forEach((category, teams) {
      teams.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    });

    if (_selectedCategoryName != null) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: _filteredTeams.length,
        itemBuilder: (context, index) => _buildTeamCard(_filteredTeams[index]),
      );
    }

    List<String> sortedCategories = teamsByCategory.keys.toList()..sort();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryTeams = teamsByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233268),
                ),
              ),
            ),
            ...categoryTeams.map(_buildTeamCard).toList(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(
                tournamentId: widget.tournament.tournamentId,
                team: team,
                tournament: widget.tournament,
              ),
            ),
          );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              child: team.logo != null && team.logo!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        team.logo!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
            ),
            title: Text(
              team.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
    );
  }
}