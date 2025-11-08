import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import '../../models/user_model.dart';

// Providers
import '../../providers/auth_provider.dart';

// Add this import for DummyDataService
import '../../services/dummy_data_service.dart';  // ← ADD THIS LINE

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Profile Section
                _buildProfileSection(user),
                // Notifications Section
                _buildNotificationsSection(),
                // App Settings Section
                _buildAppSettingsSection(),
                // Logout Button
                _buildLogoutButton(context, authProvider),
              ],
            ),
    );
  }

  Widget _buildProfileSection(AppUser user) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                child: Text(user.displayName[0].toUpperCase()),
              ),
              title: Text(user.displayName),
              subtitle: Text(user.email),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  user.isEmailVerified ? Icons.verified : Icons.warning,
                  color: user.isEmailVerified ? Colors.green : Colors.orange,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  user.isEmailVerified ? 'Email verified' : 'Email not verified',
                  style: TextStyle(
                    color: user.isEmailVerified ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Push Notifications'),
              subtitle: Text('Receive notifications for swap offers and messages'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Email Notifications'),
              subtitle: Text('Receive email updates about your swaps'),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildAppSettingsSection() {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Add this dummy data button
          ListTile(
            leading: Icon(Icons.data_usage),
            title: Text('Add Dummy Data'),
            subtitle: Text('Add sample books, offers, and chats for testing'),
            onTap: () {
              _addDummyData(context);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {
              // Navigate to help screen
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms of Service'),
            onTap: () {
              // Navigate to terms of service
            },
          ),
        ],
      ),
    ),
  );
}

// Add this method to the _SettingsScreenState class
void _addDummyData(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final dummyDataService = Provider.of<DummyDataService>(context, listen: false);
  
  if (authProvider.user != null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Dummy Data'),
        content: Text('This will add sample books, swap offers, and chat messages for testing. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Adding dummy data...'),
                    ],
                  ),
                ),
              );
              
              // Add dummy data
              await dummyDataService.initializeDummyData(authProvider.user!.id);
              
              // Hide loading
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Dummy data added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Add Data'),
          ),
        ],
      ),
    );
  }
}

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          final confirmed = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await authProvider.logout();
          }
        },
        child: Text('Logout'),
      ),
    );
  }
}