import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  /// Write activity log to top-level activities collection
  static Future<void> logActivity(
      String userId, String userName, String type, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'userId': userId,
        'userName': userName,
        'type': type,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error logging activity ($type): $e");
    }
  }
}
