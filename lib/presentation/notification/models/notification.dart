import 'notification_payload.dart';

class NotificationModel {
  String? id,
      title,
      message,
      header,
      created_date,
      modified_date,
      notification_type,
      user_uid,
      time_zone,
      dynamic_link;
  dynamic timestamp;
  NotificationPayloadModel? payload;
  bool? read;

  NotificationModel(
      this.id,
      this.title,
      this.message,
      this.header,
      this.created_date,
      this.modified_date,
      this.notification_type,
      this.user_uid,
      this.time_zone,
      this.read,
      this.payload,
      this.timestamp,
      this.dynamic_link);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'header': header,
      'created_date': created_date,
      'modified_date': modified_date,
      'notification_type': notification_type, //livestream, following
      'user_uid': user_uid,
      'time_zone': time_zone,
      'read': read,
      'payload': payload?.toJSON(),
      'timestamp': timestamp,
      'dynamic_link': dynamic_link,
    };
  }

  NotificationModel.fromSnapshot(dynamic data) {
    id = data['id'];
    title = data['title'];
    message = data['message'];
    header = data['header'];
    created_date = data['created_date'];
    modified_date = data['modified_date'];
    notification_type = data['notification_type'];
    user_uid = data['user_uid'];
    time_zone = data['time_zone'] ?? "America/Chicago";
    read = data['read'] ?? false;
    payload = NotificationPayloadModel.fromSnapshot(data['payload']);
    timestamp = data['timestamp'];
    dynamic_link = data['dynamic_link'] ?? "https://getvwave.page.link/AmFB";
  }
}
