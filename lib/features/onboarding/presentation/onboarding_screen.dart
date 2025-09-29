import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Real-Time Tracking",
      subtitle: "Track Your Journey Live",
      description: "Get real-time location updates of your bus with precise GPS tracking. Never miss your ride again!",
      icon: Icons.location_on,
      color: Color(0xFF4A90E2),
      gradient: [Color(0xFF4A90E2), Color(0xFF357ABD)],
      features: ["Live GPS Tracking", "Arrival Predictions", "Route Optimization"],
    ),
    OnboardingData(
      title: "Travel Buddy",
      subtitle: "Find Your Perfect Travel Companion",
      description: "Connect with fellow travelers on your route! Share your journey, chat safely, and make new friends while commuting.",
      icon: Icons.people_alt,
      color: Color(0xFF9C27B0),
      gradient: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      features: ["Smart Matching", "Safe Chat & Calls", "Location Sharing", "SOS Alerts"],
    ),
    OnboardingData(
      title: "Smart Experience",
      subtitle: "Book, Track & Connect",
      description: "Complete travel solution with instant booking, 3D animations, and social features - all in one beautiful app.",
      icon: Icons.auto_awesome,
      color: Color(0xFF50C878),
      gradient: [Color(0xFF50C878), Color(0xFF3EA65C)],
      features: ["Instant Booking", "3D Animations", "Digital Tickets", "Social Features"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _pages[_currentPage].gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Orbit Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Page indicators and navigation
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildPageIndicator(index),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Navigation button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _currentPage == _pages.length - 1
                            ? _finishOnboarding
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _pages[_currentPage].color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Animated Icon
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, math.sin(_floatingAnimation.value * 2 * math.pi) * 10),
                        child: Transform.rotate(
                          angle: _floatingAnimation.value * 0.1,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              data.icon,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 50),
                  
                  // Title
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Subtitle
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Description
                  Text(
                    data.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Features
                  Column(
                    children: data.features.map((feature) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              feature,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/role-selection');
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/role-selection');
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final List<String> features;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.features,
  });
}