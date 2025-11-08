import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data'; // For Uint8List

// Models
import '../../models/book_model.dart';

// Providers
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';

// Services
import '../../services/storage_service.dart';

class AddEditListingScreen extends StatefulWidget {
  final BookListing? existingListing;

  const AddEditListingScreen({this.existingListing});

  @override
  _AddEditListingScreenState createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
  BookCondition _selectedCondition = BookCondition.good;
  XFile? _pickedImage;
  String? _imageUrl;
  bool _isLoading = false;
  String? _uploadStatus;

  @override
  void initState() {
    super.initState();
    if (widget.existingListing != null) {
      _titleController.text = widget.existingListing!.title;
      _authorController.text = widget.existingListing!.author;
      _selectedCondition = widget.existingListing!.condition;
      _imageUrl = widget.existingListing!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    if (_isLoading) return;
    
    setState(() {
      _uploadStatus = 'Picking image...';
    });

    try {
      final storageService = Provider.of<StorageService>(context, listen: false);
      final image = await storageService.pickImage();
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _uploadStatus = 'Image selected - ready to upload';
        });
      } else {
        setState(() {
          _uploadStatus = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error picking image: $e';
      });
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadStatus = 'Starting upload...';
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);

      String? finalImageUrl = _imageUrl;
      
      // Upload new image if picked
      if (_pickedImage != null) {
        setState(() {
          _uploadStatus = 'Uploading image to storage...';
        });
        
        finalImageUrl = await storageService.uploadBookImage(
          _pickedImage!, 
          authProvider.user!.id
        );
        
        setState(() {
          _uploadStatus = 'Image uploaded! Saving book details...';
        });
      } else {
        setState(() {
          _uploadStatus = 'Saving book details...';
        });
      }

      final bookListing = BookListing(
        id: widget.existingListing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageUrl: finalImageUrl ?? '', // ← FIXED: Added null check with empty string fallback
        ownerId: authProvider.user!.id,
        ownerName: authProvider.user!.displayName,
        createdAt: widget.existingListing?.createdAt ?? DateTime.now(),
        isAvailable: widget.existingListing?.isAvailable ?? true,
      );

      if (widget.existingListing == null) {
        await bookProvider.addListing(bookListing);
      } else {
        await bookProvider.updateListing(bookListing);
      }

      setState(() {
        _uploadStatus = 'Book saved successfully!';
      });

      // Wait a moment to show success message
      await Future.delayed(Duration(milliseconds: 500));
      
      Navigator.of(context).pop();
      
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error saving listing: $e';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving listing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getConditionText(BookCondition condition) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingListing == null ? 'Add Listing' : 'Edit Listing'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _submitListing,
              tooltip: 'Save Listing',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildFormScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Saving Your Book...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (_uploadStatus != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _uploadStatus!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormScreen() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Image Picker Section
            _buildImagePickerSection(),
            SizedBox(height: 20),
            
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Book Title *',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter book title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Author Field
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter author name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Condition Dropdown
            DropdownButtonFormField<BookCondition>(
              value: _selectedCondition,
              decoration: InputDecoration(
                labelText: 'Condition *',
                prefixIcon: Icon(Icons.auto_awesome),
                border: OutlineInputBorder(),
              ),
              items: BookCondition.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(_getConditionText(condition)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
            ),
            SizedBox(height: 24),
            
            // Status Message
            if (_uploadStatus != null && !_isLoading)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadStatus!,
                        style: TextStyle(color: Colors.blue[800], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Submit Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitListing,
              icon: Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Listing'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            // Tips
            SizedBox(height: 20),
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Tips for Better Listings:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Use good lighting for photos'),
                    Text('• Describe any wear and tear honestly'),
                    Text('• Set a fair condition rating'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Cover Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _pickedImage != null || _imageUrl != null 
                    ? Colors.green 
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: _buildImageContent(),
          ),
        ),
        SizedBox(height: 8),
        if (_pickedImage != null || _imageUrl != null)
          Text(
            'Image ready ✓',
            style: TextStyle(color: Colors.green, fontSize: 12),
          )
        else
          Text(
            'Optional - but highly recommended',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
      ],
    );
  }

 Widget _buildImageContent() {
  if (_pickedImage != null) {
    return Stack(
      children: [
        // For web compatibility - use FutureBuilder to read image bytes
        FutureBuilder<Uint8List>(
          future: _pickedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.edit, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
    return Stack(
      children: [
        Image.network(
          _imageUrl!, 
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text('Failed to load image', style: TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.edit, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  } else {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
        SizedBox(height: 8),
        Text(
          'Tap to add book cover',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          'Makes your listing more attractive!',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }
}
  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}