class SubscriptionPlan {
  final String id;
  final String title;
  final String price;
  final String period;
  final String subtitle;
  final bool isBest;
  final String badge;
  final List<String> features;
  final int sortOrder;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    this.period = "PER WEEK",
    this.subtitle = "",
    this.isBest = false,
    this.badge = "",
    this.features = const [],
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      period: json['period']?.toString() ?? 'PER WEEK',
      subtitle: json['subtitle']?.toString() ?? '',
      isBest: json['isBest'] == true,
      badge: json['badge']?.toString() ?? '',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'period': period,
        'subtitle': subtitle,
        'isBest': isBest,
        'badge': badge,
        'features': features,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

  static const List<SubscriptionPlan> defaultPlans = [
    SubscriptionPlan(
      id: 'default_1',
      title: '3 Months',
      price: '₹99.99',
      period: 'PER WEEK',
      subtitle: 'Save 65% compared to monthly',
      isBest: true,
      badge: 'BEST VALUE',
    ),
    SubscriptionPlan(
      id: 'default_2',
      title: '1 Month',
      price: '119.99',
      period: 'PER WEEK',
      subtitle: 'Save 40%',
      isBest: false,
    ),
    SubscriptionPlan(
      id: 'default_3',
      title: '1 Week',
      price: '₹149.99',
      period: 'PER WEEK',
      subtitle: 'Flexibility first',
      isBest: false,
    ),
  ];
}

