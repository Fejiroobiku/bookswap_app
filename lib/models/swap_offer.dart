enum SwapStatus { pending, accepted, rejected, completed }

class SwapOffer {
  final String id;
  final String bookListingId;
  final String bookTitle;
  final String bookOwnerId;
  final String bookOwnerName;
  final String requesterId;
  final String requesterName;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapOffer({
    required this.id,
    required this.bookListingId,
    required this.bookTitle,
    required this.bookOwnerId,
    required this.bookOwnerName,
    required this.requesterId,
    required this.requesterName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookListingId': bookListingId,
      'bookTitle': bookTitle,
      'bookOwnerId': bookOwnerId,
      'bookOwnerName': bookOwnerName,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  static SwapOffer fromMap(Map<String, dynamic> map) {
    return SwapOffer(
      id: map['id'],
      bookListingId: map['bookListingId'],
      bookTitle: map['bookTitle'],
      bookOwnerId: map['bookOwnerId'],
      bookOwnerName: map['bookOwnerName'],
      requesterId: map['requesterId'],
      requesterName: map['requesterName'],
      status: SwapStatus.values[map['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }
}