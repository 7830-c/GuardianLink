import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login Logic with Role Validation
  Future<UserCredential?> signIn({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String actualRole = userDoc.get('role');
        if (actualRole == expectedRole) {
          return userCredential;
        } else {
          await _auth.signOut();
          throw Exception("Unauthorized: Account is registered as $actualRole.");
        }
      } else {
        throw Exception("User data not found in database.");
      }
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Registration Logic with Debug Prints
  Future<UserCredential?> register({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      // DEBUG: Step 1
      print("DEBUG: Starting registration for $email with role: $role");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // DEBUG: Step 2
      print("DEBUG: Firebase Auth success. UID: ${userCredential.user?.uid}");

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
          ...additionalData,
        });
        
        // DEBUG: Step 3
        print("DEBUG: Firestore document created successfully.");
      }
      return userCredential;
    } catch (e) {
      // DEBUG: Error catch
      print("DEBUG: Registration failed with error: $e");
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'No user found for that email.';
        case 'wrong-password': return 'Wrong password provided.';
        case 'email-already-in-use': return 'Account already exists.';
        case 'weak-password': return 'Password is too weak (min 6 chars).';
        case 'invalid-email': return 'Email format is incorrect.';
        default: return e.message ?? 'Auth error occurred.';
      }
    }
    return e.toString();
  }
}