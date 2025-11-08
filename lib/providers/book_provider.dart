import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<BookListing> _allListings = [];
  List<BookListing> _userListings = [];
  bool _isLoading = false;

  BookProvider(this._firestoreService) {
    _loadListings();
  }

  List<BookListing> get allListings => _allListings;
  List<BookListing> get userListings => _userListings;
  bool get isLoading => _isLoading;

  void _loadListings() {
    print('📚 BookProvider: Starting to load all listings...');
    _firestoreService.getBookListings().listen((listings) {
      print('✅ BookProvider: Received ${listings.length} listings from Firestore');
      _allListings = listings;
      notifyListeners();
    }, onError: (error) {
      print('❌ BookProvider: Error loading listings: $error');
    });
  }

  void loadUserListings(String userId) {
    print('👤 BookProvider: Loading listings for user: $userId');
    _firestoreService.getUserBookListings(userId).listen((listings) {
      print('✅ BookProvider: Received ${listings.length} user listings');
      _userListings = listings;
      notifyListeners();
    }, onError: (error) {
      print('❌ BookProvider: Error loading user listings: $error');
    });
  }

  Future<void> addListing(BookListing listing) async {
    print('➕ BookProvider: Adding new listing: "${listing.title}"');
    try {
      await _firestoreService.addBookListing(listing);
      print('✅ BookProvider: Listing added successfully');
      // Refresh the listings after adding
      _loadListings();
    } catch (e) {
      print('❌ BookProvider: Error adding listing: $e');
      rethrow;
    }
  }

  Future<void> updateListing(BookListing listing) async {
    await _firestoreService.updateBookListing(listing);
  }

  Future<void> deleteListing(String listingId) async {
    await _firestoreService.deleteBookListing(listingId);
  }
}