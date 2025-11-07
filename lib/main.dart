import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/post_book_screen.dart';
import 'screens/edit_book_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'providers/swaps_provider.dart';
import 'providers/chats_provider.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BookSwapApp());
}

class BookSwapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(create: (_) => SwapsProvider()),
        ChangeNotifierProvider(create: (_) => ChatsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BookSwap',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.deepPurple,
              primaryColor: Color(0xFF9C88FF), // Lilac color
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF9C88FF),
                primary: Color(0xFF9C88FF),
                secondary: Color(0xFFB19CD9),
                brightness: Brightness.light,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF9C88FF),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF9C88FF),
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                type: BottomNavigationBarType.fixed,
                elevation: 8,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.deepPurple,
              primaryColor: Color(0xFF9C88FF), // Lilac color
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF9C88FF),
                primary: Color(0xFF9C88FF),
                secondary: Color(0xFFB19CD9),
                brightness: Brightness.dark,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF7A6ACC),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                selectedItemColor: Color(0xFF9C88FF),
                unselectedItemColor: Colors.grey[400],
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                type: BottomNavigationBarType.fixed,
                elevation: 8,
              ),
              scaffoldBackgroundColor: Color(0xFF121212),
              cardColor: Color(0xFF1E1E1E),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: AuthWrapper(),
            routes: {
              '/post': (context) => PostBookScreen(),
              '/edit': (context) => EditBookScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.loading) {
      return SplashScreen();
    }

    if (auth.isSignedIn) {
      // Initialize swaps provider when user is signed in
      final swapsProv = Provider.of<SwapsProvider>(context, listen: false);
      if (auth.firebaseUser != null) {
        swapsProv.bind(auth.firebaseUser!.uid);
      }
      return HomeScreen();
    }

    return LoginScreen();
  }
}
