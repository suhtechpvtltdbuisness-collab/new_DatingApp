import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/utils/constants.dart';

/// Mock data for demo purposes
class MockData {
  // Sample user profiles for swiping
  static final List<UserModel> sampleProfiles = [
    UserModel(
      id: '1',
      email: 'sophia@example.com',
      firstName: 'Sophia',
      lastName: 'Anderson',
      phoneNumber: '+1-555-0101',
      dateOfBirth: DateTime(1995, 3, 15),
      gender: Gender.female,
      bio: 'Adventure seeker 🌍 | Coffee lover ☕ | Yoga enthusiast',
      photoUrls: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&h=500&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&h=500&fit=crop',
      ],
      city: 'Los Angeles',
      country: 'USA',
      latitude: 34.0522,
      longitude: -118.2437,
      interests: ['Travel', 'Photography', 'Hiking', 'Cooking'],
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      isVerified: true,
      isOnline: true,
    ),
    UserModel(
      id: '2',
      email: 'emma@example.com',
      firstName: 'Emma',
      lastName: 'Wilson',
      phoneNumber: '+1-555-0102',
      dateOfBirth: DateTime(1997, 7, 22),
      gender: Gender.female,
      bio: 'Artist | Dog lover | Weekend traveler',
      photoUrls: [
        'https://images.unsplash.com/photo-1517841905240-74dec2d71d1b?w=500&h=500&fit=crop',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&h=500&fit=crop',
      ],
      city: 'Austin',
      country: 'USA',
      latitude: 30.2672,
      longitude: -97.7431,
      interests: ['Art', 'Music', 'Food', 'Nature'],
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime.now(),
      lastActive: DateTime.now().subtract(Duration(hours: 2)),
      isVerified: true,
      isOnline: false,
    ),
    UserModel(
      id: '3',
      email: 'isabella@example.com',
      firstName: 'Isabella',
      lastName: 'Martinez',
      phoneNumber: '+1-555-0103',
      dateOfBirth: DateTime(1993, 11, 8),
      gender: Gender.female,
      bio: 'Fitness enthusiast 💪 | Foodie | Beach days',
      photoUrls: [
        'https://images.unsplash.com/photo-1519824145302-1cb1c4135ddd?w=500&h=500&fit=crop',
        'https://images.unsplash.com/photo-1518577915332-23a44129e529?w=500&h=500&fit=crop',
      ],
      city: 'Miami',
      country: 'USA',
      latitude: 25.7617,
      longitude: -80.1918,
      interests: ['Fitness', 'Beach', 'Cooking', 'Traveling'],
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      isVerified: true,
      isOnline: true,
    ),
    UserModel(
      id: '4',
      email: 'olivia@example.com',
      firstName: 'Olivia',
      lastName: 'Taylor',
      phoneNumber: '+1-555-0104',
      dateOfBirth: DateTime(1996, 5, 12),
      gender: Gender.female,
      bio: 'Tech writer | Movie buff | Jazz lover',
      photoUrls: [
        'https://images.unsplash.com/photo-1516846873550-cb06221eb5f7?w=500&h=500&fit=crop',
      ],
      city: 'Seattle',
      country: 'USA',
      latitude: 47.6062,
      longitude: -122.3321,
      interests: ['Technology', 'Movies', 'Music', 'Reading'],
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime.now(),
      lastActive: DateTime.now().subtract(Duration(hours: 8)),
      isVerified: false,
      isOnline: false,
    ),
    UserModel(
      id: '5',
      email: 'ava@example.com',
      firstName: 'Ava',
      lastName: 'Johnson',
      phoneNumber: '+1-555-0105',
      dateOfBirth: DateTime(1998, 9, 28),
      gender: Gender.female,
      bio: 'Fashion enthusiast | Photography lover | NYC vibes',
      photoUrls: [
        'https://images.unsplash.com/photo-1508963570623-d15395e78f5c?w=500&h=500&fit=crop',
        'https://images.unsplash.com/photo-1487412992651-a7e5dfd00a79?w=500&h=500&fit=crop',
      ],
      city: 'New York',
      country: 'USA',
      latitude: 40.7128,
      longitude: -74.0060,
      interests: ['Fashion', 'Photography', 'Shopping', 'Dining'],
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      isVerified: true,
      isOnline: true,
    ),
  ];

  // Current user profile (demo user)
  static final UserModel currentUser = UserModel(
    id: 'user123',
    email: 'demo@example.com',
    firstName: 'Alex',
    lastName: 'Smith',
    phoneNumber: '+1-555-9999',
    dateOfBirth: DateTime(1994, 4, 10),
    gender: Gender.male,
    bio: 'Developer | Traveler | Sports enthusiast',
    photoUrls: [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
    ],
    city: 'San Francisco',
    country: 'USA',
    latitude: 37.7749,
    longitude: -122.4194,
    interests: ['Technology', 'Traveling', 'Sports', 'Music'],
    relationshipStatus: RelationshipStatus.single,
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
    isVerified: true,
    isOnline: true,
  );

  // Sample matches
  static final List<MatchModel> sampleMatches = [
    MatchModel(
      id: 'match1',
      userId: 'user123',
      targetUserId: '1',
      status: MatchStatus.accepted,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      acceptedAt: DateTime.now().subtract(Duration(days: 1)),
      expiresAt: DateTime.now().add(Duration(days: 28)),
    ),
    MatchModel(
      id: 'match2',
      userId: 'user123',
      targetUserId: '2',
      status: MatchStatus.accepted,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      acceptedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 29)),
    ),
    MatchModel(
      id: 'match3',
      userId: 'user123',
      targetUserId: '3',
      status: MatchStatus.pending,
      createdAt: DateTime.now().subtract(Duration(hours: 6)),
      expiresAt: DateTime.now().add(Duration(days: 30)),
    ),
  ];

  // Sample conversations
  static final List<ConversationModel> sampleConversations = [
    ConversationModel(
      id: 'conv1',
      userId: 'user123',
      otherUserId: '1',
      otherUserName: 'Sophia Anderson',
      otherUserImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      lastMessage: "Sounds amazing! When are you free? 😊",
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
      unreadCount: 1,
      isOnline: true,
      lastSeenTime: DateTime.now(),
      messages: [],
    ),
    ConversationModel(
      id: 'conv2',
      userId: 'user123',
      otherUserId: '2',
      otherUserName: 'Emma Wilson',
      otherUserImage: 'https://images.unsplash.com/photo-1517841905240-74dec2d71d1b?w=100&h=100&fit=crop',
      lastMessage: "That sounds fun! I love hiking too 🥾",
      lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
      lastSeenTime: DateTime.now().subtract(Duration(hours: 1)),
      messages: [],
    ),
    ConversationModel(
      id: 'conv3',
      userId: 'user123',
      otherUserId: '3',
      otherUserName: 'Isabella Martinez',
      otherUserImage: 'https://images.unsplash.com/photo-1519824145302-1cb1c4135ddd?w=100&h=100&fit=crop',
      lastMessage: "Hey! How are you doing?",
      lastMessageTime: DateTime.now().subtract(Duration(hours: 6)),
      unreadCount: 3,
      isOnline: true,
      lastSeenTime: DateTime.now(),
      messages: [],
    ),
  ];

  // Sample chat messages
  static final List<ChatMessageModel> sampleChatMessages = [
    ChatMessageModel(
      id: 'msg1',
      conversationId: 'conv1',
      senderId: 'user123',
      senderName: 'Alex Smith',
      senderImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      message: 'Hey Sophia! How are you doing?',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      status: MessageStatus.read,
    ),
    ChatMessageModel(
      id: 'msg2',
      conversationId: 'conv1',
      senderId: '1',
      senderName: 'Sophia Anderson',
      senderImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      message: 'Hi Alex! I\'m doing great. Just finished yoga class 🧘‍♀️',
      timestamp: DateTime.now().subtract(Duration(minutes: 55)),
      status: MessageStatus.read,
    ),
    ChatMessageModel(
      id: 'msg3',
      conversationId: 'conv1',
      senderId: 'user123',
      senderName: 'Alex Smith',
      senderImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      message: 'That\'s awesome! I love that. Want to check out that new hiking trail this weekend?',
      timestamp: DateTime.now().subtract(Duration(minutes: 45)),
      status: MessageStatus.read,
    ),
    ChatMessageModel(
      id: 'msg4',
      conversationId: 'conv1',
      senderId: '1',
      senderName: 'Sophia Anderson',
      senderImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      message: 'Sounds amazing! When are you free? 😊',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      status: MessageStatus.delivered,
    ),
  ];

  // Helper methods
  static UserModel? getSampleProfile(String id) {
    try {
      return sampleProfiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }

  static ConversationModel? getConversation(String id) {
    try {
      return sampleConversations.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ChatMessageModel> getMessagesForConversation(String conversationId) {
    return sampleChatMessages
        .where((msg) => msg.conversationId == conversationId)
        .toList();
  }

  static List<MatchModel> getMatches() {
    return sampleMatches.toList();
  }

  static List<ConversationModel> getConversations() {
    return sampleConversations.toList();
  }
}
