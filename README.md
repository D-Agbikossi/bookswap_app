# 📚 BookSwap

A Flutter-based marketplace app where students can list textbooks they wish to exchange and initiate swap offers with other users. Built with Firebase for authentication, real-time data synchronization, and cloud storage.

## ✨ Features

### 🔐 Authentication
- **Email/Password Authentication** - Secure sign up and login
- **Email Verification** - Verify email addresses before account activation
- **User Profiles** - Each user has their own profile with customizable settings
- **Email Update** - Change email address with password verification

### 📖 Book Listings (CRUD Operations)
- **Create** - Post books with title, author, condition (New, Like New, Good, Used), and cover image
- **Read** - Browse all available listings in a shared feed
- **Update** - Edit your own book listings
- **Delete** - Remove your listings when needed

### 🔄 Swap Functionality
- **Initiate Swaps** - Request to swap with other users
- **My Offers** - View and manage received swap offers
- **Swap Status** - Track pending, accepted, and rejected swaps
- **Real-time Updates** - Instant synchronization across all devices

### 💬 Chat System
- **Per-Swap Chat** - Private messaging for each swap offer
- **Real-time Messaging** - Instant message delivery
- **Chat History** - View all conversations linked to your swaps

### 🎨 User Experience
- **Dark Mode** - Toggle between light and dark themes
- **Modern UI** - Beautiful lilac-themed interface with smooth animations
- **Loading States** - Visual feedback during async operations
- **Error Handling** - User-friendly error messages
- **Empty States** - Helpful messages when no data is available

### ⚙️ Settings
- **Profile Management** - View and update profile information
- **Notification Preferences** - Toggle push notifications
- **Theme Settings** - Switch between light and dark mode
- **Email Management** - Update email address securely

## 🛠️ Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - Image storage
- **Provider** - State management
- **Shared Preferences** - Local storage for theme preferences

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account
- Git

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bookswap_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Set up Firebase Storage
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Run FlutterFire CLI to generate `firebase_options.dart`:
     ```bash
     flutterfire configure
     ```

4. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can read/write their own user document
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Books: anyone can read, only owner can write
       match /books/{bookId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && 
           resource.data.ownerId == request.auth.uid;
       }
       
       // Swaps: users can read their own swaps, create new ones
       match /swaps/{swapId} {
         allow read: if request.auth != null && 
           (resource.data.senderId == request.auth.uid || 
            resource.data.receiverId == request.auth.uid);
         allow create: if request.auth != null;
         allow update: if request.auth != null && 
           resource.data.receiverId == request.auth.uid;
       }
       
       // Chats: users can read/write messages in their chats
       match /chats/{chatId}/messages/{messageId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Storage Security Rules**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /book_covers/{bookId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null;
       }
     }
   }
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### Getting Started
1. **Sign Up** - Create a new account with email and password
2. **Verify Email** - Check your inbox and verify your email address
3. **Post a Book** - Add your first book listing with details and cover image
4. **Browse Listings** - Explore available books from other users
5. **Initiate Swap** - Tap "Swap" on any available book
6. **Manage Offers** - Accept or reject swap offers in "My Offers" tab
7. **Chat** - Communicate with other users about swaps

### Navigation
- **Browse** - View all available book listings
- **My Listings** - Manage your posted books and received offers
- **Chats** - Access conversations related to your swaps
- **Settings** - Configure app preferences and profile

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── app_user.dart
│   ├── book.dart
│   ├── message.dart
│   └── swap_offer.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── books_provider.dart
│   ├── chats_provider.dart
│   ├── swaps_provider.dart
│   └── theme_provider.dart
├── screens/                  # UI screens
│   ├── browse_screen.dart
│   ├── chats_screen.dart
│   ├── edit_book_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── my_listings_screen.dart
│   ├── post_book_screen.dart
│   ├── settings_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
└── widgets/                  # Reusable widgets
    ├── book_tile.dart
    └── bottom_nav.dart
```

## 🏗️ Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Screens    │  │   Widgets    │  │  Navigation  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                  │              │
│         └─────────────────┴──────────────────┘            │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                      Domain Layer                           │
│                            │                                │
│         ┌──────────────────▼──────────────────┐            │
│         │         State Management             │            │
│         │  (Provider - ChangeNotifier)        │            │
│         │  ┌──────────────────────────────┐   │            │
│         │  │ AuthProvider                 │   │            │
│         │  │ BooksProvider                │   │            │
│         │  │ SwapsProvider                 │   │            │
│         │  │ ChatsProvider                 │   │            │
│         │  │ ThemeProvider                 │   │            │
│         │  └──────────────────────────────┘   │            │
│         └──────────────────┬──────────────────┘            │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                       Data Layer                            │
│                            │                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Models     │  │  Services    │  │  Firebase    │     │
│  │              │  │              │  │              │     │
│  │ - Book       │  │ - AuthService│  │ - Firestore  │     │
│  │ - AppUser    │  │ - Firestore  │  │ - Storage    │     │
│  │ - SwapOffer  │  │   Service    │  │ - Auth       │     │
│  │ - Message    │  │ - Storage    │  │              │     │
│  │              │  │   Service    │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### State Management with Provider

**Provider** is a state management solution that uses the InheritedWidget pattern to share state across the widget tree. Here's how it works in this app:

#### How Provider Works

1. **Setup**: Providers are registered at the app root using `MultiProvider`:
   ```dart
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => AuthProvider()),
       ChangeNotifierProvider(create: (_) => BooksProvider()),
       // ... other providers
     ],
   )
   ```

2. **State Classes**: Each provider extends `ChangeNotifier`:
   ```dart
   class BooksProvider extends ChangeNotifier {
     List<Book> browseBooks = [];
     
     // When data changes, call notifyListeners()
     void updateBooks(List<Book> books) {
       browseBooks = books;
       notifyListeners(); // Notifies all listening widgets
     }
   }
   ```

3. **Consuming State**: Widgets access state using `Provider.of<T>` or `Consumer<T>`:
   ```dart
   // Method 1: Provider.of (rebuilds when state changes)
   final books = Provider.of<BooksProvider>(context);
   
   // Method 2: Consumer (rebuilds only the Consumer widget)
   Consumer<BooksProvider>(
     builder: (context, books, child) {
       return Text('Books: ${books.browseBooks.length}');
     },
   )
   ```

4. **Real-time Updates**: Firestore streams automatically update state:
   ```dart
   BooksProvider() {
     _fs.browseBooksStream().listen((list) {
       browseBooks = list;
       notifyListeners(); // UI updates automatically
     });
   }
   ```

#### State Flow in BookSwap App

1. **User Action** → Widget calls provider method
2. **Provider** → Calls service method
3. **Service** → Updates Firebase (Firestore/Storage)
4. **Firebase** → Sends real-time update via stream
5. **Provider** → Receives update, calls `notifyListeners()`
6. **Widgets** → Automatically rebuild with new data

**Example Flow (Creating a Book)**:
```
User taps "Post" 
  → PostBookScreen calls booksProv.createBook()
  → BooksProvider calls firestoreService.createBook()
  → FirestoreService writes to Firebase
  → Firestore stream emits new book
  → BooksProvider.browseBooksStream() receives update
  → BooksProvider calls notifyListeners()
  → BrowseScreen automatically shows new book
```

## 🎯 Key Features Breakdown

### State Management
- Uses **Provider** pattern for reactive state management
- Real-time updates via Firestore streams
- Proper memory management with stream subscriptions
- No global setState calls (all state managed through providers)

### Real-time Synchronization
- Books, swaps, and messages update instantly across devices
- Firestore listeners provide live data updates
- Optimized queries for performance

### Image Handling
- Upload book cover images to Firebase Storage
- Automatic image compression
- Error handling for failed uploads

### Error Handling
- User-friendly error messages
- Form validation
- Network error handling
- Graceful fallbacks

## 🔧 Configuration

### Theme Customization
The app uses a lilac color scheme (`#9C88FF`). To customize:
- Edit `lib/main.dart` - Update `primaryColor` and `colorScheme`
- Modify `ThemeData` for light and dark themes

### Firebase Configuration
- Update `firebase_options.dart` after running `flutterfire configure`
- Ensure all Firebase services are enabled in the console

## 📝 Development Notes

- **State Management**: Provider pattern for all state
- **Navigation**: Named routes for main screens, modal routes for forms
- **Memory Management**: All controllers and subscriptions are properly disposed
- **Error Handling**: Comprehensive try-catch blocks with user feedback
- **Code Quality**: Follows Flutter best practices and linting rules

## 🐛 Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `firebase_options.dart` is generated
   - Check Firebase configuration files are in correct locations

2. **Authentication errors**
   - Verify Email/Password authentication is enabled in Firebase Console
   - Check Firestore security rules

3. **Image upload fails**
   - Verify Storage rules allow authenticated users
   - Check internet connection

4. **Real-time updates not working**
   - Ensure Firestore indexes are created (if needed)
   - Check network connectivity

## 📄 License

This project is part of an educational assignment.
Built as a Flutter assignment demonstrating:
- CRUD operations with Firebase
- State management with Provider
- User authentication
- Real-time data synchronization
- Full-stack mobile app development

## 👤 Author

Denaton Agbikossi

---

**Note**: This app requires an active Firebase project with proper configuration. Make sure to set up all Firebase services before running the app.
