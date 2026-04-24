import 'package:equatable/equatable.dart';

/// `GET /core/notifications/` — bitta yozuv.
class NotificationItemModel extends Equatable {
  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.image,
    required this.message,
    required this.createdAt,
    this.isRead = true,
  });

  final int id;
  final String title;
  final String icon;
  final String image;
  final String message;
  final DateTime? createdAt;
  final bool isRead;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      image: json['image'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      isRead: json['is_read'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, title, icon, image, message, createdAt, isRead];
}
