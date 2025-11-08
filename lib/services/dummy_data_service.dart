import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/swap_offer.dart';
import '../models/message.dart';

class DummyDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add dummy book listings
  Future<void> addDummyBooks() async {
    print('📚 Adding dummy books...');
    
    final dummyBooks = [
      BookListing(
        id: 'book1',
        title: 'Introduction to Algorithms',
        author: 'Thomas H. Cormen',
        condition: BookCondition.good,
        imageUrl: '', // ← Changed from null to empty string
        ownerId: 'user1',
        ownerName: 'Alex Johnson',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        isAvailable: true,
      ),
      BookListing(
        id: 'book2',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        condition: BookCondition.likeNew,
        imageUrl: '', // ← Changed from null to empty string
        ownerId: 'user2',
        ownerName: 'Sarah Miller',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        isAvailable: true,
      ),
      BookListing(
        id: 'book3',
        title: 'The Pragmatic Programmer',
        author: 'Andrew Hunt',
        condition: BookCondition.used,
        imageUrl: '', // ← Changed from null to empty string
        ownerId: 'user3',
        ownerName: 'Mike Chen',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        isAvailable: true,
      ),
      BookListing(
        id: 'book4',
        title: 'Design Patterns',
        author: 'Erich Gamma',
        condition: BookCondition.newCondition,
        imageUrl: '', // ← Changed from null to empty string
        ownerId: 'user4',
        ownerName: 'Emily Davis',
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
        isAvailable: true,
      ),
    ];

    for (final book in dummyBooks) {
      await _firestore.collection('bookListings').doc(book.id).set(book.toMap());
      print('✅ Added: ${book.title}');
    }
  }

  // Add dummy swap offers
  Future<void> addDummySwapOffers(String currentUserId) async {
    print('🔄 Adding dummy swap offers...');
    
    final dummyOffers = [
      SwapOffer(
        id: 'offer1',
        bookListingId: 'book1',
        bookTitle: 'Introduction to Algorithms',
        bookOwnerId: 'user1',
        bookOwnerName: 'Alex Johnson',
        requesterId: currentUserId,
        requesterName: 'You',
        status: SwapStatus.pending,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      SwapOffer(
        id: 'offer2',
        bookListingId: 'book2',
        bookTitle: 'Clean Code',
        bookOwnerId: 'user2',
        bookOwnerName: 'Sarah Miller',
        requesterId: 'user3',
        requesterName: 'Mike Chen',
        status: SwapStatus.pending,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];

    for (final offer in dummyOffers) {
      await _firestore.collection('swapOffers').doc(offer.id).set(offer.toMap());
      print('✅ Added swap offer for: ${offer.bookTitle}');
    }
  }

  // Add dummy chat messages
  Future<void> addDummyChats(String currentUserId) async {
    print('💬 Adding dummy chats...');
    
    // Create chat between current user and Alex Johnson
    final chatId = '${currentUserId}_user1';
    
    final messages = [
      Message(
        id: 'msg1',
        chatId: chatId,
        senderId: currentUserId,
        senderName: 'You',
        text: 'Hi! I\'m interested in your Algorithms book',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        isRead: true,
      ),
      Message(
        id: 'msg2',
        chatId: chatId,
        senderId: 'user1',
        senderName: 'Alex Johnson',
        text: 'Hey! Sure, it\'s in great condition. When do you want to meet?',
        timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: 'msg3',
        chatId: chatId,
        senderId: currentUserId,
        senderName: 'You',
        text: 'How about tomorrow at the library?',
        timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg4',
        chatId: chatId,
        senderId: 'user1',
        senderName: 'Alex Johnson',
        text: 'That works for me! 2 PM?',
        timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 15)),
        isRead: false,
      ),
    ];

    // Create chat document
    await _firestore.collection('chats').doc(chatId).set({
      'id': chatId,
      'participants': [currentUserId, 'user1'],
      'createdAt': DateTime.now().subtract(Duration(hours: 3)).millisecondsSinceEpoch,
      'lastMessage': 'That works for me! 2 PM?',
      'lastMessageTime': DateTime.now().subtract(Duration(hours: 2, minutes: 15)).millisecondsSinceEpoch,
    });

    // Add messages
    for (final message in messages) {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());
    }
    
    print('✅ Added dummy chat with Alex Johnson');
  }

  // Initialize all dummy data
  Future<void> initializeDummyData(String currentUserId) async {
    print('🎪 Initializing dummy data...');
    try {
      await addDummyBooks();
      await addDummySwapOffers(currentUserId);
      await addDummyChats(currentUserId);
      print('✅ All dummy data added successfully!');
    } catch (e) {
      print('❌ Error adding dummy data: $e');
    }
  }
}