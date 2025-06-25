import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'booking_screen.dart';
import 'reservation_screen.dart';
import 'about_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF895D50);
    const backgroundColor = Color(0xFFF8F1EC);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        title: const Text(
          'HairTime',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.25),
              BlendMode.lighten,
            ),
            child: Image.asset(
              'assets/images/fon_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Content overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildButton(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Запази час',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildButton(
                      context,
                      icon: Icons.access_time,
                      label: 'Моите резервации',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildButton(
                      context,
                      icon: Icons.spa,
                      label: 'За нас',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                  ],
                ),

                // Quote text
                const Padding(
                  padding: const EdgeInsets.only(bottom: 55.0),// повдига текста малко нагоре
                  child: Text(
                    'Време е за теб.\nКрасотата започва от тук.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 20,
                      fontWeight: FontWeight.bold, // удебелява текста
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onPressed}) {
    const primaryColor = Color(0xFF895D50);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}