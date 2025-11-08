import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_detail_screen.dart';
import '../../models/swap_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key); // ✅ Added key parameter

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    // ✅ Added null check for current user
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view chats'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'), // ✅ Added const
      ),
      body: swapProvider.receivedOffers.isEmpty && swapProvider.sentOffers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16), // ✅ Added const
                  Text(
                    'No active chats',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8), // ✅ Added const
                  Text(
                    'Start a swap to begin chatting',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                ...swapProvider.receivedOffers.where((offer) => 
                  offer.status == SwapStatus.pending || offer.status == SwapStatus.accepted
                ).map((offer) => _buildChatItem(
                  context, 
                  offer, 
                  true, 
                  currentUser.uid // ✅ Use uid instead of id
                )),
                ...swapProvider.sentOffers.where((offer) => 
                  offer.status == SwapStatus.pending || offer.status == SwapStatus.accepted
                ).map((offer) => _buildChatItem(
                  context, 
                  offer, 
                  false, 
                  currentUser.uid // ✅ Use uid instead of id
                )),
              ],
            ),
    );
  }

  Widget _buildChatItem(BuildContext context, SwapOffer offer, bool isReceived, String currentUserId) {
    // ✅ Safe handling of potentially null properties
    final otherUserName = isReceived 
        ? (offer.requesterName ?? 'Unknown User') 
        : (offer.bookOwnerName ?? 'Book Owner');
    
    final otherUserId = isReceived 
        ? offer.requesterId 
        : offer.bookOwnerId ?? '';

    // ✅ Safe first character extraction
    final avatarText = otherUserName.isNotEmpty 
        ? otherUserName[0].toUpperCase() 
        : '?';

    return ListTile(
      leading: CircleAvatar(
        child: Text(avatarText),
      ),
      title: Text(otherUserName),
      subtitle: Text(offer.bookTitle ?? 'Unknown Book'), // ✅ Null-safe book title
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ✅ Added const
        decoration: BoxDecoration(
          color: _getStatusColor(offer.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getStatusText(offer.status),
          style: const TextStyle(color: Colors.white, fontSize: 12), // ✅ Added const
        ),
      ),
      onTap: () async {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        
        // ✅ Added null check for otherUserId
        if (otherUserId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to start chat: User not found')),
          );
          return;
        }

        try {
          final chatId = await chatProvider.getOrCreateChatId(currentUserId, otherUserId);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatId: chatId,
                otherUserName: otherUserName,
                otherUserId: otherUserId,
                bookTitle: offer.bookTitle ?? 'Unknown Book', // ✅ Null-safe
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting chat: $e')),
          );
        }
      },
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
      case SwapStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusText(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
      case SwapStatus.completed:
        return 'Completed';
    }
  }
}