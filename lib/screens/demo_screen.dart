import 'package:flutter/material.dart';

class DemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookSwap Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon/Logo
            Icon(
              Icons.book,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            
            // App Title
            Text(
              'BookSwap',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Textbook Exchange App',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Features List
            _buildFeatureItem(Icons.search, 'Browse Books', 'Find textbooks from other students'),
            _buildFeatureItem(Icons.add, 'List Your Books', 'Sell or swap your old textbooks'),
            _buildFeatureItem(Icons.swap_horiz, 'Swap System', 'Easy book exchange with peers'),
            _buildFeatureItem(Icons.chat, 'In-app Chat', 'Communicate with other users'),
            
            SizedBox(height: 40),
            
            // Action Buttons
            ElevatedButton(
              onPressed: () {
                _showMessage(context, 'Login feature will be added after Firebase setup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Get Started'),
            ),
            
            SizedBox(height: 20),
            
            TextButton(
              onPressed: () {
                _showMessage(context, 'Firebase setup required for full functionality');
              },
              child: Text('Setup Instructions'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}