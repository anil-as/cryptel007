// lib/Tools/user_role_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleService {
  Future<String?> fetchUserRole(String email) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();
      if (userDoc.exists) {
        return userDoc['role'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }
}
