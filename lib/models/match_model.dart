import 'package:dating_app/utils/constants.dart';

class MatchModel {
  final String id;
  final String userId;
  final String targetUserId;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? expiresAt;
  final bool isNew;
  final int likeCount;
  final int superLikeCount;

  MatchModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.expiresAt,
    this.isNew = true,
    this.likeCount = 0,
    this.superLikeCount = 0,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isAccepted => status == MatchStatus.accepted;
  bool get isPending => status == MatchStatus.pending;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      targetUserId: json['targetUserId'] ?? '',
      status: MatchStatus.values.byName(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isNew: json['isNew'] ?? true,
      likeCount: json['likeCount'] ?? 0,
      superLikeCount: json['superLikeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetUserId': targetUserId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isNew': isNew,
      'likeCount': likeCount,
      'superLikeCount': superLikeCount,
    };
  }

  MatchModel copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? expiresAt,
    bool? isNew,
    int? likeCount,
    int? superLikeCount,
  }) {
    return MatchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isNew: isNew ?? this.isNew,
      likeCount: likeCount ?? this.likeCount,
      superLikeCount: superLikeCount ?? this.superLikeCount,
    );
  }
}
