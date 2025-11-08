import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _resendVerification() async {
    setState(() => _isLoading = true);

    // In a real app, you would call a method to resend verification email
    await Future.delayed(Duration(seconds: 2)); // Simulate API call

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification email sent!')),
    );
  }

  Future<void> _checkVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Reload user to check if email is verified
    // In a real app, you would implement this logic
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, we'll just navigate back
    // In real app, check authProvider.user?.isEmailVerified
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Icon(
                Icons.mark_email_read,
                size: 80,
                color: Colors.orange,
              ),
              SizedBox(height: 24),

              // Title
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Instructions
              Text(
                'We\'ve sent a verification email to your email address. '
                'Please check your inbox and click the verification link to activate your account.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              Text(
                'If you don\'t see the email, check your spam folder.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Resend Email Button
              if (!_emailSent)
                ElevatedButton(
                  onPressed: _isLoading ? null : _resendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Resend Verification Email',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

              // Check Verification Button
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: _checkVerification,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'I\'ve Verified My Email',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              // Back to Login
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}