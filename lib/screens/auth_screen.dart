import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin; // true = Login, false = Signup
  const AuthScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    
    if (widget.isLogin) {
      await _authService.signInWithEmail(_emailController.text, _passwordController.text);
    } else {
      await _authService.signUpWithEmail(_emailController.text, _passwordController.text);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context); // Close the screen after success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isLogin ? 'Log In to Interact' : 'Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isLogin 
                ? 'You need an account to post, comment, or react.' 
                : 'Create an account to join the community.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(widget.isLogin ? 'Log In' : 'Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
