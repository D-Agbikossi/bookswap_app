import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isUpdatingEmail = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showUpdateEmailDialog(BuildContext dialogContext) async {
    final auth = Provider.of<AuthProvider>(dialogContext, listen: false);
    final authService = AuthService();
    final currentEmail = auth.firebaseUser?.email ?? '';

    _emailController.text = currentEmail;
    _passwordController.clear();

    await showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Text('Update Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your new email address and current password to update.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  helperText: 'Required for security',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isUpdatingEmail
                ? null
                : () async {
                    if (_emailController.text.trim().isEmpty ||
                        _passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (!_emailController.text.contains('@')) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a valid email address'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => _isUpdatingEmail = true);
                    try {
                      await authService.updateEmail(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        await auth.refreshUserProfile();
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Verification email sent! Please check your new email inbox to verify.',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        String errorMessage = 'Failed to update email';
                        final errorString = e.toString().toLowerCase();
                        if (errorString.contains('wrong-password')) {
                          errorMessage = 'Incorrect password. Please try again.';
                        } else if (errorString.contains('email-already-in-use')) {
                          errorMessage =
                              'This email is already in use by another account.';
                        } else if (errorString.contains('invalid-email')) {
                          errorMessage = 'Invalid email address.';
                        }

                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(child: Text(errorMessage)),
                              ],
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isUpdatingEmail = false);
                      }
                    }
                  },
            child: _isUpdatingEmail
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
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
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text(user?.email ?? 'No email'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showUpdateEmailDialog(context),
                tooltip: 'Update email',
              ),
            ),
            Divider(),
            SwitchListTile(
              title: Text('Dark Mode'),
              subtitle: Text('Toggle dark theme'),
              value: themeProvider.isDarkMode,
              onChanged: (v) async {
                await themeProvider.setDarkMode(v);
              },
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
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
