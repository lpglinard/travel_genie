import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_data.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.user,
    this.userData,
  });

  final User user;
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    if (user.isAnonymous) {
      return const SizedBox.shrink();
    }
    
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(
        userData?.name ?? user.displayName ?? user.email ?? 'User',
      ),
      subtitle: userData?.email != null ? Text(userData!.email!) : null,
    );
  }
}