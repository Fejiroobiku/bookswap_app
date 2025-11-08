import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/book_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/auth_provider.dart';

// Widgets
import '../../widgets/book_card.dart';

// Screens
import '../book/add_edit_listing_screen.dart';

class BrowseListingsScreen extends StatefulWidget {
  @override
  _BrowseListingsScreenState createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  @override
  void initState() {
    super.initState();
    print('🔄 BrowseListingsScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final swapProvider = Provider.of<SwapProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    print('📚 Browse Screen - Book count: ${bookProvider.allListings.length}');
    print('👤 Current user: ${authProvider.user?.displayName}');
    
    // Log all books for debugging
    for (var book in bookProvider.allListings) {
      print('📖 Book: "${book.title}" by ${book.ownerName} (Available: ${book.isAvailable})');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Listings'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditListingScreen()),
              ).then((_) {
                // Refresh when returning from add screen
                print('🔄 Returning from add screen, refreshing...');
                if (authProvider.user != null) {
                  bookProvider.loadUserListings(authProvider.user!.id);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('🔄 Manual refresh triggered');
              bookProvider.loadUserListings(authProvider.user?.id ?? '');
            },
          ),
        ],
      ),
      body: _buildBody(bookProvider, swapProvider, authProvider),
    );
  }

  Widget _buildBody(BookProvider bookProvider, SwapProvider swapProvider, AuthProvider authProvider) {
    if (bookProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (bookProvider.allListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No books available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to add a book!',
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditListingScreen()),
                );
              },
              child: Text('Add First Book'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        print('🔄 Pull-to-refresh triggered');
        bookProvider.loadUserListings(authProvider.user?.id ?? '');
      },
      child: ListView.builder(
        itemCount: bookProvider.allListings.length,
        itemBuilder: (context, index) {
          final book = bookProvider.allListings[index];
          final currentUser = authProvider.user;
          
          print('🎯 Displaying book: "${book.title}" (Available: ${book.isAvailable})');
          
          return BookCard(
            book: book,
            onSwap: currentUser != null && 
                    book.ownerId != currentUser.id && 
                    book.isAvailable
                ? () {
                    swapProvider.createSwapOffer(
                      bookListingId: book.id,
                      bookTitle: book.title,
                      bookOwnerId: book.ownerId,
                      bookOwnerName: book.ownerName,
                      requesterId: currentUser.id,
                      requesterName: currentUser.displayName,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Swap offer sent for "${book.title}"!')),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }
}