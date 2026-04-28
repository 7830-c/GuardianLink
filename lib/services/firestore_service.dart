import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notifications = NotificationService();

  // 1. Registration & User Document Creation
  Future<void> createUserDocument({
    required String uid,
    required String role,
    required String name,
    required String phone,
    Map<String, dynamic>? additionalData,
  }) async {
    String collectionPath;
    switch (role) {
      case 'child': collectionPath = 'lovedOne'; break;
      case 'family': collectionPath = 'guardian'; break;
      case 'volunteer': collectionPath = 'volunteers'; break;
      case 'police': collectionPath = 'police'; break;
      default: collectionPath = 'users';
    }

    Map<String, dynamic> userData = {
      'uid': uid,
      'role': role,
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      if (role == 'child') 'guardianIds': [],
      if (role == 'family') 'lovedOnesIds': [],
      ...?additionalData,
    };

    await _db.collection(collectionPath).doc(uid).set(userData);

    // Special linking logic for Child -> Guardian
    if (role == 'child' && additionalData?['parentPhone'] != null) {
      await _linkChildToGuardian(uid, additionalData!['parentPhone']);
    }
  }

  // Linking logic: If parent's phone matches an existing guardian
  Future<void> _linkChildToGuardian(String childId, String parentPhone) async {
    // Clean phone number for reliable matching
    final cleanPhone = parentPhone.replaceAll(RegExp(r'[^0-9]'), '');
    
    QuerySnapshot guardianQuery = await _db
        .collection('guardian')
        .where('phone', isEqualTo: cleanPhone)
        .limit(1)
        .get();

    if (guardianQuery.docs.isNotEmpty) {
      DocumentSnapshot guardianDoc = guardianQuery.docs.first;
      String guardianId = guardianDoc.id;

      // Update Guardian: add childId to lovedOnesIds
      await _db.collection('guardian').doc(guardianId).update({
        'lovedOnesIds': FieldValue.arrayUnion([childId]),
      });

      // Update Child: add guardianId to guardianIds
      await _db.collection('lovedOne').doc(childId).update({
        'guardianIds': FieldValue.arrayUnion([guardianId]),
      });
    }
  }

  // 2. Token & Location Updates
  Future<void> updateFcmToken(String uid, String role, String token) async {
    String collection = _getCollectionForRole(role);
    await _db.collection(collection).doc(uid).update({'fcmToken': token});
  }

  Future<void> updateLocation(String uid, String role, double lat, double lng) async {
    String collection = _getCollectionForRole(role);
    await _db.collection(collection).doc(uid).update({
      'location': GeoPoint(lat, lng),
    });
  }

  // 3. Alerts Workflow
  Future<String> createAlert({
    required String lovedOneId,
    required double lat,
    required double lng,
  }) async {
    DocumentReference alertRef = await _db.collection('alerts').add({
      'lovedOneId': lovedOneId,
      'timestamp': FieldValue.serverTimestamp(),
      'location': GeoPoint(lat, lng),
      'status': 'pending',
      'acknowledgedBy': [],
    });
    
    // Trigger notifications (Simulated or via Cloud Functions in real world)
    await notifyResponders(lovedOneId, alertRef.id, lat, lng);
    
    return alertRef.id;
  }

  Future<void> notifyResponders(String lovedOneId, String alertId, double lat, double lng) async {
    // 1. Notify Guardians
    DocumentSnapshot childDoc = await _db.collection('lovedOne').doc(lovedOneId).get();
    if (childDoc.exists) {
      List guardianIds = childDoc.get('guardianIds') ?? [];
      for (String gId in guardianIds) {
        DocumentSnapshot gDoc = await _db.collection('guardian').doc(gId).get();
        if (gDoc.exists && gDoc.get('fcmToken') != null) {
          _sendNotification(gDoc.get('fcmToken'), lat, lng, alertId);
        }
      }
    }

    // 2. Notify Nearby Volunteers (<= 5km)
    QuerySnapshot volunteers = await _db.collection('volunteers').get();
    for (var doc in volunteers.docs) {
      GeoPoint? loc = doc.get('location');
      if (loc != null) {
        double dist = calculateDistance(lat, lng, loc.latitude, loc.longitude);
        if (dist <= 5.0 && doc.get('fcmToken') != null) {
          _sendNotification(doc.get('fcmToken'), lat, lng, alertId);
        }
      }
    }

    // 3. Notify Nearest Police Station
    QuerySnapshot policeStations = await _db.collection('police').get();
    DocumentSnapshot? nearest;
    double minDict = double.infinity;

    for (var doc in policeStations.docs) {
      GeoPoint? loc = doc.get('location');
      if (loc != null) {
        double dist = calculateDistance(lat, lng, loc.latitude, loc.longitude);
        if (dist < minDict) {
          minDict = dist;
          nearest = doc;
        }
      }
    }

    if (nearest != null && nearest.get('fcmToken') != null) {
      _sendNotification(nearest.get('fcmToken'), lat, lng, alertId);
    }
  }

  void _sendNotification(String token, double lat, double lng, String alertId) {
    _notifications.sendNotification(
      targetTokens: [token],
      title: "SOS Alert!",
      body: "Loved one needs help near your area.",
      data: {
        "lat": "$lat",
        "lng": "$lng",
        "alertId": alertId
      },
    );
  }

  Future<void> acknowledgeAlert(String alertId, String responderId) async {
    await _db.collection('alerts').doc(alertId).update({
      'status': 'acknowledged',
      'acknowledgedBy': FieldValue.arrayUnion([responderId]),
    });
  }

  // Helpers
  String _getCollectionForRole(String role) {
    switch (role) {
      case 'child': return 'lovedOne';
      case 'family': return 'guardian';
      case 'volunteer': return 'volunteers';
      case 'police': return 'police';
      default: return 'users';
    }
  }

  // Haversine Distance Calculation (for nearby logic)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
