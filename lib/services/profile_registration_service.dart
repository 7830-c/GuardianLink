import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class PoliceRegistrationLogic {
  final AuthService _auth = AuthService();

  Future<void> registerPolice(BuildContext context, String phone, String password, String name, String badgeNumber, String station, String city, double lat, double lng) async {
    try {
      await _auth.register(
        phone: phone,
        password: password,
        role: 'police',
        additionalData: {
          'name': name,
          'badgeNumber': badgeNumber,
          'station': station,
          'city': city,
          'location': GeoPoint(lat, lng),
          'isVerified': false, 
        },
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Police profile created successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

class VolunteerRegistrationLogic {
  final AuthService _auth = AuthService();

  Future<void> registerVolunteer(BuildContext context, String phone, String password, String name, List<String> skills, String roleType, double lat, double lng) async {
    try {
      await _auth.register(
        phone: phone,
        password: password,
        role: 'volunteer',
        additionalData: {
          'name': name,
          'phone': phone,
          'skills': skills,
          'roleType': roleType, // e.g., 'teacher', 'shopkeeper'
          'location': GeoPoint(lat, lng),
          'isAvailable': true,
          'rating': 0.0,
        },
      );
    } catch (e) {
       // Handle error
    }
  }
}

class FamilyRegistrationLogic {
  final AuthService _auth = AuthService();

  Future<void> registerFamily(BuildContext context, String phone, String password, String name, String relationship) async {
    try {
      await _auth.register(
        phone: phone,
        password: password,
        role: 'family',
        additionalData: {
          'name': name,
          'relationship': relationship,
          'lovedOnesIds': [], // Array of linked child IDs
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
