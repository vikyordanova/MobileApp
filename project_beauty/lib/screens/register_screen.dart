import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _register() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      _showError('Моля попълни всички полета.');
      return;
    }

    if (pass != confirmPass) {
      _showError('Паролите не съвпадат.');
      return;
    }

    try {
      final user = await _authService.register(email, pass);
      if (user != null) {
        print('✅ Успешна регистрация: ${user.email}');
        // Пренасочване към начален екран
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        _showError('Неуспешна регистрация. Опитайте отново.');
      }
    } catch (e) {
      print('⚠️ Грешка при регистрация: $e');
      _showError('Възникна неочаквана грешка. Опитайте отново.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8F1EC);
    const primaryColor = Color(0xFF895D50);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_alt_1, size: 80, color: primaryColor),
                const SizedBox(height: 20),
                const Text(
                  'Регистрация',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: primaryColor),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: emailController,
                  label: 'Имейл',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: passwordController,
                  label: 'Парола',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: confirmPasswordController,
                  label: 'Повтори паролата',
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Регистрирай се', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    const primaryColor = Color(0xFF895D50);
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: primaryColor),
          onPressed: _togglePasswordVisibility,
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
