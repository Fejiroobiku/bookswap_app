import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadBookImage(XFile imageFile, String userId) async {
    try {
      print('📤 Starting image upload for user: $userId');
      
      String fileName = 'book_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      
      print('📁 Uploading to: $fileName');
      
      // For web compatibility - convert XFile to bytes
      final bytes = await imageFile.readAsBytes();
      
      UploadTask uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📈 Upload progress: ${progress.toStringAsFixed(1)}%');
      });
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully!');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  Future<XFile?> pickImage() async {
    try {
      print('🖼️ Picking image from gallery...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('✅ Image picked: ${image.name}');
      } else {
        print('❌ No image selected');
      }
      
      return image;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }
}