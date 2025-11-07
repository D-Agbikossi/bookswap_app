import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool emailVerified;
  final bool notificationsEnabled;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.emailVerified = false,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }
}
