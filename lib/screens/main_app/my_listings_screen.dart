import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import '../../models/book_model.dart';
import '../../models/swap_offer.dart';

// Providers
import '../../providers/book_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/auth_provider.dart';

// Widgets
import '../../widgets/book_card.dart';

// Screens
import '../book/add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final swapProvider = Provider.of<SwapProvider>(context);

    // Load user listings when screen builds
    if (authProvider.user != null) {
      bookProvider.loadUserListings(authProvider.user!.id);
      swapProvider.loadUserOffers(authProvider.user!.id);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Listings'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'My Books'),
              Tab(text: 'Swap Offers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Books Tab
            _buildMyBooksTab(context, bookProvider, authProvider),
            // Swap Offers Tab
            _buildSwapOffersTab(context, swapProvider),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditListingScreen()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMyBooksTab(BuildContext context, BookProvider bookProvider, AuthProvider authProvider) {
    return bookProvider.isLoading
        ? Center(child: CircularProgressIndicator())
        : bookProvider.userListings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No books listed yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first book',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: bookProvider.userListings.length,
                itemBuilder: (context, index) {
                  final book = bookProvider.userListings[index];
                  return Dismissible(
                    key: Key(book.id),
                    background: Container(color: Colors.red),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Listing'),
                          content: Text('Are you sure you want to delete "${book.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      bookProvider.deleteListing(book.id);
                    },
                    child: BookCard(
                      book: book,
                      onSwap: null, // No swap button on own listings
                    ),
                  );
                },
              );
  }

  Widget _buildSwapOffersTab(BuildContext context, SwapProvider swapProvider) {
    return ListView(
      children: [
        // Received Offers
        _buildOfferSection(
          context,
          title: 'Received Offers',
          offers: swapProvider.receivedOffers,
          isReceived: true,
        ),
        // Sent Offers
        _buildOfferSection(
          context,
          title: 'Sent Offers',
          offers: swapProvider.sentOffers,
          isReceived: false,
        ),
      ],
    );
  }

  Widget _buildOfferSection(BuildContext context, {
    required String title,
    required List<SwapOffer> offers,
    required bool isReceived,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (offers.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No ${title.toLowerCase()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ...offers.map((offer) => _buildOfferCard(context, offer, isReceived)),
      ],
    );
  }

  Widget _buildOfferCard(BuildContext context, SwapOffer offer, bool isReceived) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.bookTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              isReceived
                  ? 'From: ${offer.requesterName}'
                  : 'To: ${offer.bookOwnerName}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(offer.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(offer.status),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Spacer(),
                if (isReceived && offer.status == SwapStatus.pending)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Provider.of<SwapProvider>(context, listen: false)
                              .updateOfferStatus(offer.id, SwapStatus.accepted);
                        },
                        child: Text('Accept', style: TextStyle(color: Colors.green)),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<SwapProvider>(context, listen: false)
                              .updateOfferStatus(offer.id, SwapStatus.rejected);
                        },
                        child: Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                if (!isReceived && offer.status == SwapStatus.pending)
                  TextButton(
                    onPressed: () {
                      Provider.of<SwapProvider>(context, listen: false)
                          .cancelSwapOffer(offer.id);
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.orange)),
                  ),
              ],
            ),
          ],
        ),
      ),
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