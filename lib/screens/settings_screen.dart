import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userProfile;
    final firebaseUser = auth.firebaseUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  user?.displayName.isNotEmpty == true
                      ? user!.displayName[0].toUpperCase()
                      : 'U',
                ),
              ),
              title: Text(user?.displayName ?? 'No name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.email ?? ''),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        firebaseUser?.emailVerified == true
                            ? Icons.verified
                            : Icons.warning,
                        size: 16,
                        color: firebaseUser?.emailVerified == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        firebaseUser?.emailVerified == true
                            ? 'Email verified'
                            : 'Email not verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: firebaseUser?.emailVerified == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (firebaseUser?.emailVerified == false) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification email sent! Check your inbox.'),
                      ),
                    );
                  },
                  icon: Icon(Icons.email),
                  label: Text('Resend Verification Email'),
                ),
              ),
            ],
            Divider(),
            SwitchListTile(
              title: Text('Notifications'),
              subtitle: Text('Enable push notifications'),
              value: user?.notificationsEnabled ?? true,
              onChanged: (v) async {
                if (user != null) {
                  final updated = AppUser(
                    uid: user.uid,
                    email: user.email,
                    displayName: user.displayName,
                    photoUrl: user.photoUrl,
                    emailVerified: user.emailVerified,
                    notificationsEnabled: v,
                  );
                  await authService.updateProfile(updated);
                  // Refresh user profile
                  await auth.refreshUserProfile();
                }
              },
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  await auth.signOut();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
