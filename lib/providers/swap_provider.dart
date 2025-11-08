import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/swap_offer.dart';

class SwapProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<SwapOffer> _sentOffers = [];
  List<SwapOffer> _receivedOffers = [];
  bool _isLoading = false;

  SwapProvider(this._firestoreService);

  List<SwapOffer> get sentOffers => _sentOffers;
  List<SwapOffer> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;

  void loadUserOffers(String userId) {
    _firestoreService.getSwapOffersForUser(userId).listen((offers) {
      _receivedOffers = offers;
      notifyListeners();
    });

    _firestoreService.getSwapRequestsByUser(userId).listen((offers) {
      _sentOffers = offers;
      notifyListeners();
    });
  }

  Future<void> createSwapOffer({
    required String bookListingId,
    required String bookTitle,
    required String bookOwnerId,
    required String bookOwnerName,
    required String requesterId,
    required String requesterName,
  }) async {
    final offer = SwapOffer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookListingId: bookListingId,
      bookTitle: bookTitle,
      bookOwnerId: bookOwnerId,
      bookOwnerName: bookOwnerName,
      requesterId: requesterId,
      requesterName: requesterName,
      status: SwapStatus.pending,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createSwapOffer(offer);
  }

  Future<void> updateOfferStatus(String offerId, SwapStatus status) async {
    await _firestoreService.updateSwapOfferStatus(offerId, status);
  }

  Future<void> cancelSwapOffer(String offerId) async {
    await _firestoreService.updateSwapOfferStatus(offerId, SwapStatus.rejected);
  }
}