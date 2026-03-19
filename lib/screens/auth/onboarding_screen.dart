import 'package:flutter/material.dart';
import 'package:dating_app/screens/auth/create_account.dart';


class ModernOnboardingScreen extends StatelessWidget {
  const ModernOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E7FF), Color(0xFFFFE3EC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Logo
              const Text(
                "#Hookup",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 40),

              /// Card Stack Section
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCard(
                      image: "assets/images/girlimage1.png",
                      name: "Justin, 25",
                      location: "New York",
                      rotation: -8,
                      bottom: 0,
                    ),
                    _buildCard(
                      image: "assets/images/boyimage.png",
                      name: "Julia Lode, 23",
                      location: "Los Angeles",
                      rotation: 8,
                      bottom: 20,
                    ),

                    /// Floating Icons
                    Positioned(
                      left: 40,
                      top: 80,
                      child: _circleIcon(Icons.card_giftcard, Colors.purple),
                    ),
                    Positioned(
                      right: 40,
                      top: 60,
                      child: _circleIcon(Icons.chat_bubble, Colors.blue),
                    ),
                    Positioned(
                      right: 50,
                      bottom: 30,
                      child: _circleIcon(Icons.favorite, Colors.pink),
                    ),
                  ],
                ),
              ),

              /// Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Find Your\n",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: "Perfect Match",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Meet New People, Spark Real Connections, And See Where It Goes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              /// Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border),
                        SizedBox(width: 10),
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile Card Widget (for Network/Asset Images)
  static Widget _buildCard({
    required String image,
    required String name,
    required String location,
    required double rotation,
    required double bottom,
  }) {
    return Positioned(
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation * 0.0174533,
        child: Container(
          width: 240,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(location, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SVG card helper removed — using local asset PNG cards via `_buildCard`.

  static Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
