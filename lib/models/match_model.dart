import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/constants.dart';

class MatchModel {
  final UserModel? matchedUser;
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
    this.matchedUser,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isAccepted => status == MatchStatus.accepted;
  bool get isPending => status == MatchStatus.pending;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final matchedUser = json['matchedUser'];
    final targetUser = matchedUser is Map<String, dynamic>
        ? matchedUser
        : user is Map<String, dynamic>
            ? user
            : null;
    final resolvedStatus = _parseStatus(json['status']);

    return MatchModel(
      id: (json['id'] ?? json['_id'] ?? targetUser?['_id'] ?? targetUser?['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['fromUserId'] ?? '').toString(),
      targetUserId: (json['targetUserId'] ??
              json['toUserId'] ??
              targetUser?['_id'] ??
              targetUser?['id'] ??
              '')
          .toString(),
      status: resolvedStatus,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.tryParse(json['acceptedAt'].toString())
          : null,
      expiresAt:
          json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      isNew: json['isNew'] ?? true,
      likeCount: json['likeCount'] ?? 0,
      superLikeCount: json['superLikeCount'] ?? 0,
      matchedUser: targetUser != null ? UserModel.fromJson(targetUser) : null,
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
      matchedUser: matchedUser,
    );
  }

  static MatchStatus _parseStatus(dynamic value) {
    final normalized = value?.toString().toLowerCase();

    if (normalized == null || normalized.isEmpty) {
      return MatchStatus.accepted;
    }

    return MatchStatus.values.firstWhere(
      (status) => status.name == normalized,
      orElse: () => MatchStatus.accepted,
    );
  }
}
