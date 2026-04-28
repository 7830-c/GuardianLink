import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  // Helper for password hashing (as requested)
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _getProxyEmail(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return "$cleanPhone@guardianlink.ai";
  }

  // Login Logic
  Future<UserCredential?> signIn({
    required String phone,
    required String password,
    required String expectedRole,
    double? lat,
    double? lng,
  }) async {
    try {
      String email = _getProxyEmail(phone);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      // Verify role and update data
      String collection = _getCollectionForRole(expectedRole);
      QuerySnapshot userQuery = await _firestore
          .collection(collection)
          .where('phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        String docId = userQuery.docs.first.id;
        
        // 1. Update FCM Token
        String? token = await _notificationService.getDeviceToken();
        if (token != null) {
          await _firestoreService.updateFcmToken(docId, expectedRole, token);
        }

        // 2. Update Location (for volunteers and police)
        if (lat != null && lng != null && (expectedRole == 'volunteer' || expectedRole == 'police')) {
          await _firestoreService.updateLocation(docId, expectedRole, lat, lng);
        }

        return userCredential;
      } else {
        await _auth.signOut();
        throw Exception("Account not found in $expectedRole database.");
      }
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Registration Logic
  Future<UserCredential?> register({
    required String phone,
    required String password,
    required String role,
    required Map<String, dynamic> additionalData,
    double? lat,
    double? lng,
  }) async {
    try {
      String email = _getProxyEmail(phone);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String? token = await _notificationService.getDeviceToken();
        
        final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
        // Create Firestore Document using our new Service
        await _firestoreService.createUserDocument(
          uid: userCredential.user!.uid, // We'll still store UID for auth linking
          role: role,
          name: additionalData['name'] ?? '',
          phone: cleanPhone,
          additionalData: {
            ...additionalData,
            'password': _hashPassword(password), // Storing hashed password as requested
            'fcmToken': token,
            if (lat != null && lng != null) 'location': GeoPoint(lat, lng),
          },
        );
      }
      return userCredential;
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  String _getCollectionForRole(String role) {
    switch (role) {
      case 'child': return 'lovedOne';
      case 'family': return 'guardian';
      case 'volunteer': return 'volunteers';
      case 'police': return 'police';
      default: return 'users';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'No account found with this phone number.';
        case 'wrong-password': return 'Incorrect password.';
        case 'email-already-in-use': return 'Account already exists.';
        case 'weak-password': return 'Password is too weak (min 6 chars).';
        default: return e.message ?? 'Authentication error occurred.';
      }
    }
    return e.toString();
  }
}