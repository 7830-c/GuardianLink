import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class AlertService {
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifications = NotificationService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> triggerSosAlert({
    required String lovedOneId,
    required double lat,
    required double lng,
  }) async {
    // 0. Check for existing active alerts
    QuerySnapshot existing = await _db.collection('alerts')
        .where('lovedOneId', isEqualTo: lovedOneId)
        .where('status', isEqualTo: 'pending')
        .get();
        
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    // 1. Create Alert Document
    String alertId = await _firestore.createAlert(lovedOneId: lovedOneId, lat: lat, lng: lng);

    // 2. Fetch Loved One Details to get Guardian IDs
    DocumentSnapshot lovedOneDoc = await _db.collection('lovedOne').doc(lovedOneId).get();
    if (!lovedOneDoc.exists) return alertId;

    List<dynamic> guardianIds = lovedOneDoc.get('guardianIds') ?? [];
    
    // 3. Notify Guardians
    List<String> guardianTokens = [];
    for (String gId in guardianIds) {
      DocumentSnapshot gDoc = await _db.collection('guardian').doc(gId).get();
      if (gDoc.exists && gDoc.get('fcmToken') != null) {
        guardianTokens.add(gDoc.get('fcmToken'));
      }
    }
    
    if (guardianTokens.isNotEmpty) {
      await _notifications.sendNotification(
        targetTokens: guardianTokens,
        title: "SOS Alert!",
        body: "Loved one needs help near your area.",
        data: {"lat": lat.toString(), "lng": lng.toString(), "alertId": alertId},
      );
    }

    // 4. Notify Nearby Volunteers (within 5km)
    QuerySnapshot volunteerSnapshot = await _db.collection('volunteers').get();
    List<String> volunteerTokens = [];
    for (var vDoc in volunteerSnapshot.docs) {
      GeoPoint? vLoc = vDoc.get('location');
      if (vLoc != null) {
        double dist = _firestore.calculateDistance(lat, lng, vLoc.latitude, vLoc.longitude);
        if (dist <= 5.0 && vDoc.get('fcmToken') != null) {
          volunteerTokens.add(vDoc.get('fcmToken'));
        }
      }
    }

    if (volunteerTokens.isNotEmpty) {
      await _notifications.sendNotification(
        targetTokens: volunteerTokens,
        title: "Volunteer SOS!",
        body: "Someone needs help within 5km of your location.",
        data: {"lat": lat.toString(), "lng": lng.toString(), "alertId": alertId},
      );
    }

    // 5. Notify Nearest Police Station
    QuerySnapshot policeSnapshot = await _db.collection('police').get();
    String? nearestStation;
    double minDist = double.infinity;
    List<String> policeTokens = [];

    for (var pDoc in policeSnapshot.docs) {
      GeoPoint? pLoc = pDoc.get('location');
      if (pLoc != null) {
        double dist = _firestore.calculateDistance(lat, lng, pLoc.latitude, pLoc.longitude);
        if (dist < minDist) {
          minDist = dist;
          nearestStation = pDoc.get('station');
        }
      }
    }

    if (nearestStation != null) {
      // Find all officers at that station
      QuerySnapshot stationOfficers = await _db
          .collection('police')
          .where('station', isEqualTo: nearestStation)
          .get();
          
      for (var pDoc in stationOfficers.docs) {
        if (pDoc.get('fcmToken') != null) {
          policeTokens.add(pDoc.get('fcmToken'));
        }
      }
    }

    if (policeTokens.isNotEmpty) {
      await _notifications.sendNotification(
        targetTokens: policeTokens,
        title: "Police Dispatch SOS!",
        body: "Critical emergency reported near your station area.",
        data: {"lat": lat.toString(), "lng": lng.toString(), "alertId": alertId},
      );
    }
    
    return alertId;
  }
}
