
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vwave/presentation/notification/models/notification.dart';
import 'package:vwave/utils/general.dart';

class NotificationRepository {

  late CollectionReference<Map<String, dynamic>> collectionReference;
  BuildContext context;

  NotificationRepository(this.context) {
    collectionReference = FirebaseFirestore.instance.collection("notifications");
  }

  Future<void> updateNotificationReadStatus(NotificationModel notificationModel) async {
    collectionReference.doc(notificationModel.id).update({"read": true});
  }

  Future<void> updateNotificationData(NotificationModel notificationModel, Map<String, dynamic> data) async {
    collectionReference.doc(notificationModel.id).update(data);
  }

}