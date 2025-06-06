import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/services/auth_service.dart';
import 'package:aviron_castrais_rugby/services/referee_service.dart';
import 'package:intl/intl.dart';

class RefereeMatchesScreen extends StatefulWidget {
  const RefereeMatchesScreen({super.key});

  @override
  State<RefereeMatchesScreen> createState() => _RefereeMatchesScreenState();
}

class _RefereeMatchesScreenState extends State<RefereeMatchesScreen> {
  final AuthService _authService = AuthService();
  final RefereeService _refereeService = RefereeService();
  List<RefereeGame> _games = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSessionAndLoadGames();
  }

  Future<void> _checkSessionAndLoadGames() async {
    // Si pas de session, retourner à l'écran de connexion
    if (!AuthService.isLoggedIn) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée, veuillez vous reconnecter'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    _loadGames();
  }

  Future<void> _loadGames() async {
    if (AuthService.refereeId == null) {
      setState(() {
        _error = 'Vous devez être connecté pour voir vos matchs';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Un seul appel API - les noms d'équipes sont déjà inclus dans la réponse
      final games = await _refereeService.getRefereeGames(AuthService.refereeId!);

      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Horaire non défini';
    }
    final formatter = DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR');
    String formatted = formatter.format(dateTime);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF233268),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mes Matchs',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (AuthService.refereeFirstName != null)
              Text(
                'Bonjour ${AuthService.refereeFirstName!}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            // Déconnecter l'arbitre et retourner à l'écran précédent
            await _authService.logout();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGames,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorWidget()
            : _games.isEmpty
            ? _buildEmptyWidget()
            : _buildGamesList(),
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
              onPressed: _loadGames,
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
          Icon(Icons.sports_rugby, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun match assigné'),
          SizedBox(height: 8),
          Text(
            'Vos matchs apparaîtront ici une fois assignés',
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

  Widget _buildGamesList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        return _buildGameCard(game);
      },
    );
  }

  Widget _buildGameCard(RefereeGame game) {
    final isCompleted = game.isCompleted;
    final isPast = game.startTime?.isBefore(DateTime.now()) ?? false;
    
    // Utiliser directement les noms d'équipes de l'API
    final team1DisplayName = game.team1Name ?? 'Équipe ${game.team1Id}';
    final team2DisplayName = game.team2Name ?? 'Équipe ${game.team2Id}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isCompleted ? null : () => _showEditMatchDialog(game),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: isCompleted
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.white,
                      ],
                    )
                  : isPast
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.white,
                      ],
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut du match
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green
                              : isPast
                              ? Colors.orange
                              : game.startTime == null
                              ? Colors.grey
                              : const Color(0xFF233268),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCompleted 
                              ? 'Terminé'
                              : isPast
                              ? 'En cours'
                              : game.startTime == null
                              ? 'Programmé'
                              : 'À venir',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            game.fieldId != null ? 'Terrain ${game.fieldId}' : 'Terrain non assigné',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (game.ageCategory != null) ...[
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF233268).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                game.ageCategory!.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF233268),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Équipes et score
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                team1DisplayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCompleted) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${game.team1Score}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF233268),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF233268),
                              ),
                            ),
                            if (isCompleted)
                              const Text(
                                'Score final',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                team2DisplayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCompleted) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${game.team2Score}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF233268),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date et heure
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          game.startTime == null ? Icons.schedule : Icons.access_time,
                          size: 20,
                          color: game.startTime == null ? Colors.grey : const Color(0xFF233268),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDateTime(game.startTime),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: game.startTime == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Indication pour édition
                  if (!isCompleted) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF233268).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 16, color: Color(0xFF233268)),
                          SizedBox(width: 4),
                          Text(
                            'Toucher pour éditer le score',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF233268),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditMatchDialog(RefereeGame game) {
    final team1ScoreController = TextEditingController(text: game.team1Score.toString());
    final team2ScoreController = TextEditingController(text: game.team2Score.toString());
    bool isCompleted = false;

    // Utiliser directement les noms d'équipes de l'API
    final team1DisplayName = game.team1Name ?? 'Équipe ${game.team1Id}';
    final team2DisplayName = game.team2Name ?? 'Équipe ${game.team2Id}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Éditer le match'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Équipes
                    Text(
                      '$team1DisplayName vs $team2DisplayName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Scores
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                team1DisplayName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: team1ScoreController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Score',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                team2DisplayName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: team2ScoreController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Score',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Match terminé
                    CheckboxListTile(
                      title: const Text('Match terminé ?'),
                      subtitle: const Text('Cocher si le match est fini'),
                      value: isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          isCompleted = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => _saveMatch(
                    game,
                    int.tryParse(team1ScoreController.text) ?? 0,
                    int.tryParse(team2ScoreController.text) ?? 0,
                    isCompleted,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF233268),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveMatch(RefereeGame game, int team1Score, int team2Score, bool isCompleted) {
    if (isCompleted) {
      // Double confirmation pour marquer comme terminé
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text(
              'Êtes-vous sûr de vouloir marquer ce match comme terminé ?\n\nCette action ne peut pas être annulée.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateMatch(game, team1Score, team2Score, isCompleted);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmer'),
              ),
            ],
          );
        },
      );
    } else {
      _updateMatch(game, team1Score, team2Score, isCompleted);
    }
  }

  Future<void> _updateMatch(RefereeGame game, int team1Score, int team2Score, bool isCompleted) async {
    try {
      // Fermer le dialog d'édition
      Navigator.of(context).pop();
      
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await _refereeService.updateMatch(
        game.gameId,
        team1Score: team1Score,
        team2Score: team2Score,
        isCompleted: isCompleted,
        startTime: game.startTime,
        team1Id: game.team1Id,
        team2Id: game.team2Id,
        refereeId: game.refereeId,
        poolId: game.poolId,
        fieldId: game.fieldId,
      );

      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      // Recharger les matchs
      await _loadGames();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCompleted ? 'Match marqué comme terminé' : 'Score mis à jour'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
