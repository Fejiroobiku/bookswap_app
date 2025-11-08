import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition { newCondition, likeNew, good, used }

class BookListing {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final bool isAvailable;

  BookListing({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    required this.isAvailable,
  });

  String get conditionString {
    switch (condition) {
      case BookCondition.newCondition:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'condition': condition.index,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isAvailable': isAvailable,
    };
  }

  static BookListing fromMap(Map<String, dynamic> map) {
    print('🔄 Converting map to BookListing: $map');
    
    // Handle different timestamp formats
    dynamic createdAtValue = map['createdAt'];
    DateTime createdAt;
    
    if (createdAtValue is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
    } else if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else {
      print('❌ Unknown createdAt type: ${createdAtValue.runtimeType}');
      createdAt = DateTime.now();
    }
    
    // Handle condition - ensure it's an integer
    dynamic conditionValue = map['condition'];
    int conditionIndex;
    
    if (conditionValue is int) {
      conditionIndex = conditionValue;
    } else {
      print('❌ Condition is not int: ${conditionValue.runtimeType}');
      conditionIndex = 2;
    }
    
    return BookListing(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      condition: BookCondition.values[conditionIndex],
      imageUrl: map['imageUrl']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      createdAt: createdAt,
      isAvailable: map['isAvailable'] == true,
    );
  }
}