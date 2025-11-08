import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AppUser?> get user {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      print('🔥 Firebase auth state changed: ${firebaseUser?.email}');
      
      if (firebaseUser != null) {
        print('👤 Getting user data for: ${firebaseUser.uid}');
        final userData = await _getUserData(firebaseUser.uid);
        if (userData != null) {
          print('✅ User data retrieved successfully');
        } else {
          print('❌ User data not found in Firestore');
        }
        return userData;
      } else {
        print('🚫 No user logged in');
        return null;
      }
    });
  }

  Future<AppUser?> _getUserData(String uid) async {
    try {
      print('📖 Fetching user data from Firestore for: $uid');
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        print('✅ User document exists in Firestore');
        return AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        print('❌ User document does not exist in Firestore');
        // Try to create user document if it doesn't exist
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          print('🔄 Creating missing user document...');
          final newUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName ?? 'User',
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(uid).set(newUser.toMap());
          print('✅ Created missing user document');
          return newUser;
        }
        return null;
      }
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  Future<String?> register(String email, String password, String displayName) async {
    try {
      print('🚀 Starting Firebase registration...');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        print('✅ Firebase user created: ${user.uid}');
        
        // Update display name
        await user.updateDisplayName(displayName);
        
        // Send email verification
        await user.sendEmailVerification();
        print('📧 Verification email sent');

        // Create user document in Firestore
        AppUser appUser = AppUser(
          id: user.uid,
          email: user.email!,
          displayName: displayName,
          isEmailVerified: false,
          createdAt: DateTime.now(),
        );

        print('💾 Saving user to Firestore...');
        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        print('✅ User saved to Firestore');

        return null;
      }
      return 'Registration failed - no user created';
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('❌ Registration error: $e');
      return 'Registration failed: $e';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      print('🚀 Starting Firebase login...');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase login successful: ${result.user?.email}');
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('❌ Login error: $e');
      return 'Login failed: $e';
    }
  }

  Future<void> logout() async {
    print('🚪 Firebase logout');
    await _auth.signOut();
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }
}