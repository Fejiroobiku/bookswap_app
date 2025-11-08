import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample chat data for demonstration
    final List<Map<String, dynamic>> sampleChats = [
      {
        'id': 'chat1',
        'otherUserName': 'Alex Johnson',
        'bookTitle': 'Introduction to Algorithms',
        'lastMessage': 'That works for me! 2 PM?',
        'timestamp': '2h ago',
        'unread': true,
      },
      {
        'id': 'chat2', 
        'otherUserName': 'Sarah Miller',
        'bookTitle': 'Clean Code',
        'lastMessage': 'I can meet on Friday',
        'timestamp': '1d ago',
        'unread': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: sampleChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No active chats',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a swap to begin chatting',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to browse to start a swap
                    },
                    child: Text('Browse Books'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sampleChats.length,
              itemBuilder: (context, index) {
                final chat = sampleChats[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        chat['otherUserName']![0],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(chat['otherUserName']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['bookTitle']!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(chat['lastMessage']!),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat['timestamp']!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        if (chat['unread'] as bool)
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      _showChatDetail(context, chat);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showChatDetail(BuildContext context, Map<String, dynamic> chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat with ${chat['otherUserName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About: ${chat['bookTitle']}'),
            SizedBox(height: 16),
            Text('This is a sample chat. In the full version, you would see the actual message history here.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}