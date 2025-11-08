import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/message_bubble.dart'; 
import '../../models/message_model.dart'; 

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;
  final String bookTitle;

  const ChatDetailScreen({
    Key? key, // ✅ Added key parameter
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
    required this.bookTitle,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadChatMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    // ✅ Added null check for current user
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send messages')),
      );
      return;
    }

    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      chatProvider.sendMessage(
        chatId: widget.chatId,
        senderId: currentUser.uid, // ✅ Use uid instead of id
        senderName: currentUser.displayName ?? 'Unknown User', // ✅ Null-safe
        text: messageText,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            Text(
              widget.bookTitle,
              style: const TextStyle( // ✅ Added const
                fontSize: 12, 
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatProvider.getChatStream(widget.chatId),
              builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // ✅ Added const
                }

                if (snapshot.hasError) {
                  return const Center( // ✅ Added const
                    child: Text('Error loading messages'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center( // ✅ Added const
                    child: Text('No messages yet'),
                  );
                }

                final List<Message> messages = snapshot.data!;
                
                // Schedule scroll to bottom after build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16), // ✅ Added const
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Message message = messages[index];
                    
                    // ✅ Safe user ID comparison with null check
                    final bool isMe = currentUser != null && 
                        message.senderId == currentUser.uid;
                    
                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16), // ✅ Added const
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [ // ✅ Added const
                BoxShadow(
                  offset: Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16), // ✅ Added const
                    ),
                    onSubmitted: (String value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8), // ✅ Added const
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white), // ✅ Added const
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}