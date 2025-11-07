import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get firebaseUserChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await sendEmailVerification();
    // create user doc
    final appUser = AppUser(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
      emailVerified: cred.user!.emailVerified,
    );
    await _db.collection('users').doc(cred.user!.uid).set(appUser.toMap());
    return cred;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Enforce email verification - user cannot log in until verified
    if (cred.user != null && !cred.user!.emailVerified) {
      await _auth.signOut(); // Sign out the unverified user
      throw Exception('email-not-verified');
    }
    
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> fetchAppUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Future<void> updateProfile(AppUser user) async {
    final data = user.toMap();
    data.remove('uid'); // Don't update the uid field
    await _db.collection('users').doc(user.uid).update(data);
  }

  Future<void> updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    // Re-authenticate user before changing email
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // Update email in Firebase Auth
    await user.verifyBeforeUpdateEmail(newEmail);

    // Update email in Firestore
    await _db.collection('users').doc(user.uid).update({'email': newEmail});
  }
}
