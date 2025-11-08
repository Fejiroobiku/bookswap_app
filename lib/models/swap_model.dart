class SwapOffer {
  final String id;
  final String bookId;
  final String requesterId;
  final String ownerId;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? offeredBookId;
  final String? message;
  
  // ✅ Make sure these properties exist
  final String? bookTitle;
  final String? requesterName;
  final String? bookOwnerName;
  final String? bookOwnerId;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.requesterId,
    required this.ownerId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.offeredBookId,
    this.message,
    this.bookTitle,
    this.requesterName,
    this.bookOwnerName,
    this.bookOwnerId,
  });

  // ... rest of your model methods
}