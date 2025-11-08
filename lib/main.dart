import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Services
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/dummy_data_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/swap_provider.dart';
import 'providers/chat_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/main_app/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA2wR_r74dMKaLeCYb1mVC6vRBRx5TMAws",
        authDomain: "bookswapapp-8f3f1.firebaseapp.com",
        projectId: "bookswapapp-8f3f1",
        storageBucket: "bookswapapp-8f3f1.firebasestorage.app",
        messagingSenderId: "909442636205",
        appId: "1:909442636205:web:36d2a2716427cd1673a924",
      ),
    );
    print('🔥 Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<DummyDataService>(create: (_) => DummyDataService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<BookProvider>(
          create: (context) => BookProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<SwapProvider>(
          create: (context) => SwapProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(context.read<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Color(0xFF16A34A),
          hintColor: Color(0xFF22C55E),
          scaffoldBackgroundColor: Color(0xFFF0FDF4),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF16A34A),
            elevation: 2,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF16A34A),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF16A34A),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    print('🔄 AuthWrapper - isLoading: ${authProvider.isLoading}');
    print('🔐 AuthWrapper - isLoggedIn: ${authProvider.isLoggedIn}');
    print('👤 AuthWrapper - user: ${authProvider.user}');
    
    if (authProvider.isLoading) {
      print('⏳ Showing loading screen');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
              ),
              SizedBox(height: 20),
              Text(
                'Loading BookSwap...',
                style: TextStyle(color: Color(0xFF166534)),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!authProvider.isLoggedIn) {
      print('🚪 Showing login screen - user not logged in');
      return LoginScreen();
    }
    
    print('🎉 Showing main app - user is logged in!');
    return MainAppScreen();
  }
}