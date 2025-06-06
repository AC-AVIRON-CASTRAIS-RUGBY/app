import 'package:flutter/material.dart';
import 'package:aviron_castrais_rugby/screens/home_screen.dart';
import 'package:aviron_castrais_rugby/screens/shop_screen.dart';
import 'package:aviron_castrais_rugby/screens/referee_home_screen.dart';
import 'package:aviron_castrais_rugby/screens/news_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          ShopScreen(
            onNavigateToTournaments: () {
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          const HomeScreen(),
          const NewsScreen(),
          const RefereeHomeScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF233268),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Boutique
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == 0 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: _currentPage == 0 ? Colors.white : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Boutique',
                        style: TextStyle(
                          color: _currentPage == 0 ? Colors.white : Colors.white70,
                          fontSize: 9,
                          fontWeight: _currentPage == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tournois
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == 1 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_rugby,
                        color: _currentPage == 1 ? Colors.white : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tournois',
                        style: TextStyle(
                          color: _currentPage == 1 ? Colors.white : Colors.white70,
                          fontSize: 9,
                          fontWeight: _currentPage == 1 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actualités
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == 2 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.article,
                        color: _currentPage == 2 ? Colors.white : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Actualités',
                        style: TextStyle(
                          color: _currentPage == 2 ? Colors.white : Colors.white70,
                          fontSize: 9,
                          fontWeight: _currentPage == 2 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Arbitres
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    3,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == 3 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: _currentPage == 3 ? Colors.white : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Arbitres',
                        style: TextStyle(
                          color: _currentPage == 3 ? Colors.white : Colors.white70,
                          fontSize: 9,
                          fontWeight: _currentPage == 3 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
