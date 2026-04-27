import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class PoliceRegistrationLogic {
  final AuthService _auth = AuthService();

  Future<void> registerPolice(BuildContext context, String email, String password, String name, String badgeNumber, String station) async {
    try {
      await _auth.register(
        email: email,
        password: password,
        role: 'police',
        additionalData: {
          'name': name,
          'badgeNumber': badgeNumber,
          'station': station,
          'isVerified': false, // Requires admin verification later
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Police profile created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

class VolunteerRegistrationLogic {
  final AuthService _auth = AuthService();

  Future<void> registerVolunteer(BuildContext context, String email, String password, String name, String phone, List<String> skills) async {
    try {
      await _auth.register(
        email: email,
        password: password,
        role: 'volunteer',
        additionalData: {
          'name': name,
          'phone': phone,
          'skills': skills, // e.g., ['First Aid', 'CPR']
          'isAvailable': true,
          'rating': 0.0, // Default rating
        },
      );
    } catch (e) {
       // Handle error
    }
  }
}

class FamilyRegistrationLogic {
  final AuthService _auth = AuthService();

  Future<void> registerFamily(BuildContext context, String email, String password, String name, String relationship) async {
    try {
      await _auth.register(
        email: email,
        password: password,
        role: 'family',
        additionalData: {
          'name': name,
          'relationship': relationship,
          'linkedLovedOnes': [], // Array of UIDs for loved ones they monitor
        },
      );
    } catch (e) {
       // Handle error
    }
  }
}

Future<Map<String, dynamic>?> getUserProfile() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser != null) {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
        
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
  }
  return null;
}
