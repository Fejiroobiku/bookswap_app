import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/swap_offer.dart';
import '../models/message.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Book Listings CRUD - SIMPLIFIED VERSION (no composite indexes needed)
  Stream<List<BookListing>> getBookListings() {
    print('🔥 FirestoreService: Using simple query for book listings...');
    return _firestore
        .collection('bookListings')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('✅ FirestoreService: Retrieved ${snapshot.docs.length} book listings');
          
          // Convert to BookListing objects
          final listings = snapshot.docs
              .map((doc) => BookListing.fromMap(doc.data()))
              .toList();
              
          // Manual sort by createdAt (newest first)
          listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          print('✅ Sorted ${listings.length} books manually');
          return listings;
        });
  }

  Stream<List<BookListing>> getUserBookListings(String userId) {
    print('🔥 FirestoreService: Using simple query for user listings...');
    return _firestore
        .collection('bookListings')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('✅ FirestoreService: Retrieved ${snapshot.docs.length} user listings');
          
          // Convert to BookListing objects
          final listings = snapshot.docs
              .map((doc) => BookListing.fromMap(doc.data()))
              .toList();
              
          // Manual sort by createdAt (newest first)
          listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return listings;
        });
  }

  // Swap Offers - SIMPLIFIED VERSION
  Stream<List<SwapOffer>> getSwapOffersForUser(String userId) {
    print('🔥 FirestoreService: Using simple query for swap offers...');
    return _firestore
        .collection('swapOffers')
        .where('bookOwnerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('✅ FirestoreService: Retrieved ${snapshot.docs.length} swap offers');
          
          // Convert to SwapOffer objects
          final offers = snapshot.docs
              .map((doc) => SwapOffer.fromMap(doc.data()))
              .toList();
              
          // Manual sort by createdAt (newest first)
          offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return offers;
        });
  }

  Stream<List<SwapOffer>> getSwapRequestsByUser(String userId) {
    print('🔥 FirestoreService: Using simple query for swap requests...');
    return _firestore
        .collection('swapOffers')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('✅ FirestoreService: Retrieved ${snapshot.docs.length} swap requests');
          
          // Convert to SwapOffer objects
          final requests = snapshot.docs
              .map((doc) => SwapOffer.fromMap(doc.data()))
              .toList();
              
          // Manual sort by createdAt (newest first)
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return requests;
        });
  }

  // The rest of your methods stay the same
  Future<void> addBookListing(BookListing listing) async {
    print('➕ FirestoreService: Adding book listing: "${listing.title}"');
    try {
      await _firestore.collection('bookListings').doc(listing.id).set(listing.toMap());
      print('✅ FirestoreService: Book listing added successfully!');
    } catch (e) {
      print('❌ FirestoreService: Error adding book listing: $e');
      rethrow;
    }
  }

  Future<void> updateBookListing(BookListing listing) async {
    await _firestore.collection('bookListings').doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteBookListing(String listingId) async {
    await _firestore.collection('bookListings').doc(listingId).delete();
  }

  Future<void> createSwapOffer(SwapOffer offer) async {
    await _firestore.collection('swapOffers').doc(offer.id).set(offer.toMap());
    
    // Update book listing availability
    await _firestore.collection('bookListings').doc(offer.bookListingId).update({
      'isAvailable': false,
    });
  }

  Future<void> updateSwapOfferStatus(String offerId, SwapStatus status) async {
    await _firestore.collection('swapOffers').doc(offerId).update({
      'status': status.index,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Chat Methods (unchanged)
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(Message message) async {
    await _firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<String> getOrCreateChatId(String user1Id, String user2Id) async {
    List<String> participants = [user1Id, user2Id]..sort();
    String chatId = participants.join('_');

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'id': chatId,
        'participants': participants,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return chatId;
  }
}