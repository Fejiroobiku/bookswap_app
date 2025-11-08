import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookListing book;
  final VoidCallback? onSwap;
  final VoidCallback? onTap;

  const BookCard({
    required this.book,
    this.onSwap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCover(),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getConditionColor(book.condition),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.conditionString,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        if (onSwap != null && book.isAvailable)
                          ElevatedButton(
                            onPressed: onSwap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              'Swap',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Listed by ${book.ownerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover() {
    print('📖 Building book cover for: ${book.title}');
    print('🖼️ Image URL: ${book.imageUrl}');
    print('🖼️ Image URL is empty: ${book.imageUrl.isEmpty}');
    
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFFDCFCE7),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: book.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: book.imageUrl,
                fit: BoxFit.cover,
                width: 80,
                height: 100,
                placeholder: (context, url) => Container(
                  color: Color(0xFFDCFCE7),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  print('❌ Error loading image: $error');
                  print('❌ Image URL that failed: $url');
                  return Container(
                    color: Color(0xFFDCFCE7),
                    child: Icon(
                      Icons.book,
                      color: Color(0xFF16A34A),
                      size: 30,
                    ),
                  );
                },
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFDCFCE7),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    color: Color(0xFF16A34A),
                    size: 30,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No Image',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.newCondition:
        return Color(0xFF16A34A);
      case BookCondition.likeNew:
        return Color(0xFF22C55E);
      case BookCondition.good:
        return Color(0xFF84CC16);
      case BookCondition.used:
        return Color(0xFFCA8A04);
    }
  }
}