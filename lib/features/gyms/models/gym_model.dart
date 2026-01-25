import 'package:equatable/equatable.dart';

/// Gym model representing a gym location.
class GymModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String address;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final List<String>? images;
  final List<String>? amenities;
  final List<String>? equipment;
  final Map<String, dynamic>? operatingHours;
  final int capacity;
  final int currentOccupancy;
  final bool is24Hours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GymModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.address,
    required this.city,
    this.state,
    required this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.images,
    this.amenities,
    this.equipment,
    this.operatingHours,
    this.capacity = 100,
    this.currentOccupancy = 0,
    this.is24Hours = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'US',
      postalCode: json['postal_code'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      images: _parseStringList(json['images']),
      amenities: _parseStringList(json['amenities']),
      equipment: _parseStringList(json['equipment']),
      operatingHours: json['operating_hours'] as Map<String, dynamic>?,
      capacity: json['capacity'] as int? ?? 100,
      currentOccupancy: json['current_occupancy'] as int? ?? 0,
      is24Hours: json['is_24_hours'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'images': images,
      'amenities': amenities,
      'equipment': equipment,
      'operating_hours': operatingHours,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'is_24_hours': is24Hours,
      'is_active': isActive,
    };
  }

  /// Get occupancy percentage (0.0 to 1.0).
  double get occupancyPercentage {
    if (capacity == 0) return 0.0;
    return (currentOccupancy / capacity).clamp(0.0, 1.0);
  }

  /// Get occupancy status.
  OccupancyStatus get occupancyStatus {
    final percentage = occupancyPercentage;
    if (percentage < 0.4) return OccupancyStatus.notBusy;
    if (percentage < 0.7) return OccupancyStatus.moderate;
    if (percentage < 0.9) return OccupancyStatus.busy;
    return OccupancyStatus.full;
  }

  /// Check if gym is currently open.
  bool get isOpen {
    if (is24Hours) return true;
    if (operatingHours == null) return true;

    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final hours = operatingHours![dayName.toLowerCase()];

    if (hours == null) return false;

    try {
      final openTime = _parseTime(hours['open']);
      final closeTime = _parseTime(hours['close']);

      if (openTime == null || closeTime == null) return false;

      final currentMinutes = now.hour * 60 + now.minute;
      final openMinutes = openTime.hour * 60 + openTime.minute;
      final closeMinutes = closeTime.hour * 60 + closeTime.minute;

      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    } catch (e) {
      return false;
    }
  }

  /// Get today's operating hours string.
  String? get todaysHours {
    if (is24Hours) return 'Open 24 Hours';
    if (operatingHours == null) return null;

    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final hours = operatingHours![dayName.toLowerCase()];

    if (hours == null) return 'Closed';

    try {
      final open = hours['open'] as String?;
      final close = hours['close'] as String?;
      if (open == null || close == null) return null;

      return '$open - $close';
    } catch (e) {
      return null;
    }
  }

  /// Get full address string.
  String get fullAddress {
    final parts = <String>[
      address,
      city,
      if (state != null) state!,
      if (postalCode != null) postalCode!,
      country,
    ];
    return parts.join(', ');
  }

  // Helper parsing methods
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  static DateTime? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }

  static String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        address,
        city,
        state,
        country,
        postalCode,
        latitude,
        longitude,
        phone,
        email,
        website,
        logoUrl,
        images,
        amenities,
        equipment,
        operatingHours,
        capacity,
        currentOccupancy,
        is24Hours,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Gym occupancy status enum.
enum OccupancyStatus {
  notBusy,
  moderate,
  busy,
  full,
}

/// Extension for occupancy status display.
extension OccupancyStatusExtension on OccupancyStatus {
  String get displayName {
    switch (this) {
      case OccupancyStatus.notBusy:
        return 'Not Busy';
      case OccupancyStatus.moderate:
        return 'Moderate';
      case OccupancyStatus.busy:
        return 'Busy';
      case OccupancyStatus.full:
        return 'Full';
    }
  }

  String get emoji {
    switch (this) {
      case OccupancyStatus.notBusy:
        return '🟢';
      case OccupancyStatus.moderate:
        return '🟡';
      case OccupancyStatus.busy:
        return '🟠';
      case OccupancyStatus.full:
        return '🔴';
    }
  }
}
