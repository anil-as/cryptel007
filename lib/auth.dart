import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null && user.email != null) {
        DocumentReference userDocRef =
            _firestore.collection('users').doc(user.email);

        if (userCredential.additionalUserInfo!.isNewUser) {
          // Add the data to Firestore with email as the document ID
          await userDocRef.set({
            'username': user.displayName,
            'uid': user.uid,
            'profilePhoto': user.photoURL,
            'email': user.email,
            'role': 'Customer',
            'access': 'Requesting', // Default access status
            'createdAt':
                FieldValue.serverTimestamp(), // Add timestamp for creation
          });
        } else {
          // If the user already exists, retrieve the access status
          DocumentSnapshot userDoc = await userDocRef.get();
          String? accessStatus = userDoc['access'];

          return accessStatus; // Return the access status
        }
      }
    } catch (e) {
      print('Failed to sign in with Google: $e');
      return null;
    }
    return 'Requesting'; // Return 'Requesting' for new users
  }

  void signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Cannot sign out: $e');
    }
  }
}
