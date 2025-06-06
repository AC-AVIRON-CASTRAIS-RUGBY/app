import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/models/schedule.dart';
import 'package:aviron_castrais_rugby/services/tournament_service.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

class MatchDetailScreen extends StatefulWidget {
  final Game game;
  final String poolName;

  const MatchDetailScreen({
    Key? key,
    required this.game,
    required this.poolName,
  }) : super(key: key);

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final TournamentService _tournamentService = TournamentService();
  Map<String, dynamic>? _matchDetails;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  
  // Variables pour suivre les scores et déclencher les confettis
  int _previousTeam1Score = 0;
  int _previousTeam2Score = 0;
  Game? _currentGame;
  
  // Variable pour contrôler l'actualisation automatique
  bool _autoRefreshEnabled = true;
  
  // Contrôleurs de confettis
  late ConfettiController _confettiController1;
  late ConfettiController _confettiController2;
  late ConfettiController _confettiControllerCenter;

  @override
  void initState() {
    super.initState();
    _currentGame = widget.game;
    _previousTeam1Score = widget.game.team1.score;
    _previousTeam2Score = widget.game.team2.score;
    
    // Initialiser les contrôleurs de confettis
    _confettiController1 = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController2 = ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerCenter = ConfettiController(duration: const Duration(seconds: 5));
    
    _loadMatchDetails();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // Actualiser toutes les 10 secondes si le match n'est pas terminé et si l'auto-refresh est activé
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _currentGame != null && !_currentGame!.isCompleted && _autoRefreshEnabled) {
        _loadMatchDetails(silent: true);
      } else if (_currentGame?.isCompleted == true) {
        // Arrêter l'actualisation si le match est terminé
        timer.cancel();
      }
    });
  }

  void _toggleAutoRefresh(bool value) {
    setState(() {
      _autoRefreshEnabled = value;
    });
    
    if (value && _currentGame != null && !_currentGame!.isCompleted) {
      // Redémarrer le timer si l'auto-refresh est réactivé
      _refreshTimer?.cancel();
      _startAutoRefresh();
    } else if (!value) {
      // Arrêter le timer si l'auto-refresh est désactivé
      _refreshTimer?.cancel();
    }
  }

  Future<void> _loadMatchDetails({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final details = await _tournamentService.getMatchDetails(widget.game.gameId);
      
      // Créer un nouvel objet Game avec les détails mis à jour
      if (details.containsKey('team1Score') && details.containsKey('team2Score')) {
        final newGame = Game(
          gameId: _currentGame!.gameId,
          startTime: _currentGame!.startTime,
          team1: TeamScore(
            id: _currentGame!.team1.id,
            name: _currentGame!.team1.name,
            score: details['team1Score'] ?? _currentGame!.team1.score,
          ),
          team2: TeamScore(
            id: _currentGame!.team2.id,
            name: _currentGame!.team2.name,
            score: details['team2Score'] ?? _currentGame!.team2.score,
          ),
          referee: _currentGame!.referee,
          field: _currentGame!.field,
          isCompleted: details['isCompleted'] ?? _currentGame!.isCompleted,
        );
        
        // Vérifier si des buts ont été marqués
        _checkForNewGoals(newGame);
        
        _currentGame = newGame;
      }

      setState(() {
        _matchDetails = details;
        if (!silent) _isLoading = false;
      });
    } catch (e) {
      if (!silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _checkForNewGoals(Game newGame) {
    // Vérifier si l'équipe 1 a marqué
    if (newGame.team1.score > _previousTeam1Score) {
      _triggerConfetti(1);
      _showGoalNotification(newGame.team1.name, newGame.team1.score - _previousTeam1Score);
    }
    
    // Vérifier si l'équipe 2 a marqué
    if (newGame.team2.score > _previousTeam2Score) {
      _triggerConfetti(2);
      _showGoalNotification(newGame.team2.name, newGame.team2.score - _previousTeam2Score);
    }
    
    // Si le match vient de se terminer, déclencher des confettis spéciaux
    if (!_currentGame!.isCompleted && newGame.isCompleted) {
      _triggerEndGameConfetti();
    }
    
    // Mettre à jour les scores précédents
    _previousTeam1Score = newGame.team1.score;
    _previousTeam2Score = newGame.team2.score;
  }

  void _triggerConfetti(int team) {
    if (team == 1) {
      _confettiController1.play();
    } else {
      _confettiController2.play();
    }
  }

  void _triggerEndGameConfetti() {
    _confettiControllerCenter.play();
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController1.play();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _confettiController2.play();
    });
  }

  void _showGoalNotification(String teamName, int goals) {
    final message = goals == 1 ? 'Essai de $teamName !' : '$goals essais de $teamName !';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sports_soccer, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _confettiController1.dispose();
    _confettiController2.dispose();
    _confettiControllerCenter.dispose();
    _tournamentService.dispose();
    super.dispose();
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR');
      String formatted = formatter.format(dateTime);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF233268),
        title: const Text(
          'Détails du match',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _loadMatchDetails(),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _buildMatchDetail(),
          ),
          
          // Confettis pour l'équipe 1 (gauche)
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController1,
              blastDirection: 0, // Direction vers la droite
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              colors: const [Colors.blue, Colors.lightBlue, Colors.cyan],
            ),
          ),
          
          // Confettis pour l'équipe 2 (droite)
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController2,
              blastDirection: 3.14159, // Direction vers la gauche
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              colors: const [Colors.red, Colors.pink, Colors.orange],
            ),
          ),
          
          // Confettis centraux pour la fin de match
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiControllerCenter,
              blastDirection: -3.14159 / 2, // Direction vers le bas
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.03,
              numberOfParticles: 50,
              gravity: 0.05,
              colors: const [
                Colors.white,
                Colors.yellow,
                Colors.orange,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.purple
              ],
            ),
          ),
        ],
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
              onPressed: () => _loadMatchDetails(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchDetail() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte principale avec score et détails du match (fond bleu dégradé)
          _buildMainMatchCard(),
          
          const SizedBox(height: 16),
          
          // Option actualisation automatique (hors de la carte)
          if (!_currentGame!.isCompleted) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildAutoRefreshOption(),
          ),
          
          const SizedBox(height: 16),
          
          // Bloc informations sur le match
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMatchInfoCard(),
          ),
          
          const SizedBox(height: 16),
          
          // Détails supplémentaires
          if (_matchDetails != null) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildAdditionalDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMatchCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF233268),
            const Color(0xFF233268).withOpacity(0.8),
            const Color(0xFF233268).withOpacity(0.6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Date du match (centrée verticalement)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _formatDate(_currentGame!.startTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Heure du match
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_currentGame!.startTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Terrain
            if (_currentGame!.field != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stadium, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentGame!.field}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 20),
            ],
            
            // Scores dans un carré blanc
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Noms des équipes
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentGame!.team1.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233268),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233268),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _currentGame!.team2.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233268),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Scores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF233268).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF233268),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_currentGame!.team1.score}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF233268),
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF233268),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF233268).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF233268),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_currentGame!.team2.score}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF233268),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Texte du score
                  Text(
                    _currentGame!.isCompleted ? 'Score final' : 'Score actuel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bouton de statut orange
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _currentGame!.isCompleted ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentGame!.isCompleted ? Icons.check_circle : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentGame!.isCompleted ? 'TERMINÉ' : (_isMatchStarted() ? 'EN COURS' : 'À VENIR'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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

  Widget _buildAutoRefreshOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: 24,
            color: _autoRefreshEnabled ? const Color(0xFF233268) : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualisation automatique',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _autoRefreshEnabled ? const Color(0xFF233268) : Colors.grey,
                  ),
                ),
                Text(
                  'Mise à jour toutes les 10 secondes',
                  style: TextStyle(
                    fontSize: 12,
                    color: _autoRefreshEnabled ? Colors.grey[600] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoRefreshEnabled,
            onChanged: _toggleAutoRefresh,
            activeColor: const Color(0xFF233268),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du match',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233268),
              ),
            ),
            const SizedBox(height: 20),
            
            // Arbitre
            _buildInfoRow(
              Icons.sports,
              'Arbitre',
              _currentGame!.referee,
            ),
            
            const SizedBox(height: 16),
            
            // ID du match
            _buildInfoRow(
              Icons.tag,
              'ID du match',
              _currentGame!.gameId.toString(),
            ),
            
            const SizedBox(height: 16),
            
            // Poule
            _buildInfoRow(
              Icons.group,
              'Poule',
              widget.poolName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF233268)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails supplémentaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233268),
              ),
            ),
            const SizedBox(height: 16),
            
            // Afficher les détails supplémentaires si disponibles
            if (_matchDetails!.containsKey('additionalInfo'))
              Text(_matchDetails!['additionalInfo'].toString()),
            
            // Match ID pour référence
            _buildInfoRow(
              Icons.tag,
              'ID du match',
              _currentGame!.gameId.toString(),
            ),
          ],
        ),
      ),
    );
  }

  bool _isMatchStarted() {
    try {
      final matchTime = DateTime.parse(_currentGame!.startTime);
      return DateTime.now().isAfter(matchTime);
    } catch (e) {
      return false;
    }
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
      String formatted = formatter.format(dateTime);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return dateTimeStr;
    }
  }
}
