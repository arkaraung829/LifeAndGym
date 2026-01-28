import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/gym_model.dart';
import '../providers/gym_provider.dart';

/// Screen displaying list of gyms with search and filter capabilities.
class GymListScreen extends StatefulWidget {
  const GymListScreen({super.key});

  @override
  State<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends State<GymListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<String> _selectedAmenities = [];
  bool _showOpenOnly = false;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGyms();
      _loadLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    await context.read<GymProvider>().loadGyms();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await LocationService.instance.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<GymProvider>().searchGyms(query);
    });
  }

  String _getDistanceText(GymModel gym) {
    if (_currentPosition == null) {
      return '-- km away';
    }

    if (gym.latitude == null || gym.longitude == null) {
      return '-- km away';
    }

    final distanceInMeters = LocationService.instance.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      gym.latitude!,
      gym.longitude!,
    );

    return '${LocationService.instance.formatDistance(distanceInMeters)} away';
  }

  List<GymModel> _sortByDistance(List<GymModel> gyms) {
    if (_currentPosition == null) {
      return gyms;
    }

    final gymsWithDistance = gyms.map((gym) {
      double? distance;
      if (gym.latitude != null && gym.longitude != null) {
        distance = LocationService.instance.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          gym.latitude!,
          gym.longitude!,
        );
      }
      return MapEntry(gym, distance);
    }).toList();

    // Sort: gyms with coordinates first (by distance), then gyms without coordinates
    gymsWithDistance.sort((a, b) {
      if (a.value == null && b.value == null) return 0;
      if (a.value == null) return 1;
      if (b.value == null) return -1;
      return a.value!.compareTo(b.value!);
    });

    return gymsWithDistance.map((e) => e.key).toList();
  }

  List<GymModel> _getFilteredGyms(List<GymModel> gyms) {
    var filtered = gyms;

    // Filter by open status
    if (_showOpenOnly) {
      filtered = filtered.where((gym) => gym.isOpen).toList();
    }

    // Filter by amenities
    if (_selectedAmenities.isNotEmpty) {
      filtered = filtered.where((gym) {
        if (gym.amenities == null) return false;
        return _selectedAmenities.every(
          (amenity) => gym.amenities!.contains(amenity),
        );
      }).toList();
    }

    // Sort by distance if location is available
    filtered = _sortByDistance(filtered);

    return filtered;
  }

  void _showFilterDialog() {
    // Get all unique amenities from gyms
    final provider = context.read<GymProvider>();
    final allAmenities = <String>{};
    for (final gym in provider.gyms) {
      if (gym.amenities != null) {
        allAmenities.addAll(gym.amenities!);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Gyms'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Open Now filter
                CheckboxListTile(
                  title: const Text('Open Now'),
                  value: _showOpenOnly,
                  onChanged: (value) {
                    setDialogState(() {
                      _showOpenOnly = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                if (allAmenities.isNotEmpty) ...[
                  Text(
                    'Amenities',
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  ...allAmenities.map((amenity) => CheckboxListTile(
                        title: Text(amenity),
                        value: _selectedAmenities.contains(amenity),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedAmenities.clear();
                _showOpenOnly = false;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
  }

  void _showGymDetails(GymModel gym) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GymDetailBottomSheet(gym: gym),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Gyms'),
        actions: [
          // Location refresh button
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Refresh location',
              onPressed: () {
                LocationService.instance.clearCache();
                _loadLocation();
              },
            ),
          // Filter button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              if (_selectedAmenities.isNotEmpty || _showOpenOnly)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: AppSpacing.paddingMd,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search gyms by name or city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Gym list
          Expanded(
            child: Consumer<GymProvider>(
              builder: (context, provider, child) {
                // Loading state
                if (provider.isLoading && provider.gyms.isEmpty) {
                  return const Center(child: LoadingIndicator());
                }

                // Error state
                if (provider.state == GymState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error ?? 'Failed to load gyms',
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGyms,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredGyms = _getFilteredGyms(provider.gyms);

                // Empty state
                if (filteredGyms.isEmpty) {
                  final hasSearchQuery = _searchController.text.isNotEmpty;
                  final hasFilters =
                      _selectedAmenities.isNotEmpty || _showOpenOnly;

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasSearchQuery || hasFilters
                              ? Icons.search_off
                              : Icons.fitness_center,
                          size: 64,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasSearchQuery
                              ? 'No results for "${_searchController.text}"'
                              : hasFilters
                                  ? 'No gyms match the selected filters'
                                  : 'No gyms found',
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        if (hasSearchQuery || hasFilters) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedAmenities.clear();
                                _showOpenOnly = false;
                              });
                              _onSearchChanged('');
                            },
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Gym list
                return RefreshIndicator(
                  onRefresh: () async {
                    await _loadGyms();
                    LocationService.instance.clearCache();
                    await _loadLocation();
                  },
                  child: ListView.builder(
                    padding: AppSpacing.paddingMd,
                    itemCount: filteredGyms.length,
                    itemBuilder: (context, index) {
                      final gym = filteredGyms[index];
                      return _GymCard(
                        gym: gym,
                        onTap: () => _showGymDetails(gym),
                        distanceText: _getDistanceText(gym),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Gym card widget.
class _GymCard extends StatelessWidget {
  final GymModel gym;
  final VoidCallback onTap;
  final String distanceText;

  const _GymCard({
    required this.gym,
    required this.onTap,
    required this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gym name and logo
          Row(
            children: [
              // Logo or placeholder
              if (gym.logoUrl != null)
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: Image.network(
                    gym.logoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildLogoPlaceholder(),
                  ),
                )
              else
                _buildLogoPlaceholder(),
              const SizedBox(width: AppSpacing.md),
              // Gym name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name,
                      style: AppTypography.heading4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${gym.city}${gym.state != null ? ", ${gym.state}" : ""}',
                            style: AppTypography.caption.copyWith(
                              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Occupancy and operating hours
          Row(
            children: [
              // Occupancy badge
              _OccupancyBadge(gym: gym),
              const SizedBox(width: AppSpacing.md),
              // Operating status
              _OperatingStatusBadge(gym: gym),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Amenities
          if (gym.amenities != null && gym.amenities!.isNotEmpty)
            _AmenitiesRow(amenities: gym.amenities!),

          // Distance
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                size: 14,
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                distanceText,
                style: AppTypography.caption.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: const Icon(
        Icons.fitness_center,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

/// Occupancy badge widget.
class _OccupancyBadge extends StatelessWidget {
  final GymModel gym;

  const _OccupancyBadge({required this.gym});

  @override
  Widget build(BuildContext context) {
    final percentage = (gym.occupancyPercentage * 100).toInt();
    final status = gym.occupancyStatus;

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OccupancyStatus.notBusy:
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green;
        break;
      case OccupancyStatus.moderate:
        backgroundColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange;
        break;
      case OccupancyStatus.busy:
        backgroundColor = Colors.deepOrange.withValues(alpha: 0.15);
        textColor = Colors.deepOrange;
        break;
      case OccupancyStatus.full:
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$percentage% capacity',
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Operating status badge widget.
class _OperatingStatusBadge extends StatelessWidget {
  final GymModel gym;

  const _OperatingStatusBadge({required this.gym});

  @override
  Widget build(BuildContext context) {
    final isOpen = gym.isOpen;
    final todaysHours = gym.todaysHours;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.access_time : Icons.lock_clock,
            size: 14,
            color: isOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: AppTypography.caption.copyWith(
              color: isOpen ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (todaysHours != null) ...[
            const SizedBox(width: 4),
            Text(
              todaysHours,
              style: AppTypography.caption.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Amenities row widget.
class _AmenitiesRow extends StatelessWidget {
  final List<String> amenities;

  const _AmenitiesRow({required this.amenities});

  @override
  Widget build(BuildContext context) {
    final displayAmenities = amenities.take(3).toList();
    final remainingCount = amenities.length - displayAmenities.length;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        ...displayAmenities.map((amenity) => _AmenityChip(amenity: amenity)),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Text(
              '+$remainingCount more',
              style: AppTypography.caption.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

/// Amenity chip widget.
class _AmenityChip extends StatelessWidget {
  final String amenity;

  const _AmenityChip({required this.amenity});

  IconData _getAmenityIcon(String amenity) {
    final lowerAmenity = amenity.toLowerCase();
    if (lowerAmenity.contains('wifi')) return Icons.wifi;
    if (lowerAmenity.contains('parking')) return Icons.local_parking;
    if (lowerAmenity.contains('locker')) return Icons.lock;
    if (lowerAmenity.contains('shower')) return Icons.shower;
    if (lowerAmenity.contains('sauna')) return Icons.hot_tub;
    if (lowerAmenity.contains('pool')) return Icons.pool;
    if (lowerAmenity.contains('cafe')) return Icons.local_cafe;
    if (lowerAmenity.contains('store')) return Icons.store;
    if (lowerAmenity.contains('trainer')) return Icons.person;
    if (lowerAmenity.contains('class')) return Icons.group;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAmenityIcon(amenity),
            size: 12,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            amenity,
            style: AppTypography.caption.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gym detail bottom sheet widget.
class _GymDetailBottomSheet extends StatelessWidget {
  final GymModel gym;

  const _GymDetailBottomSheet({required this.gym});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with logo
                      Row(
                        children: [
                          if (gym.logoUrl != null)
                            ClipRRect(
                              borderRadius: AppSpacing.borderRadiusMd,
                              child: Image.network(
                                gym.logoUrl!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildLogoPlaceholder(),
                              ),
                            )
                          else
                            _buildLogoPlaceholder(),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gym.name,
                                  style: AppTypography.heading2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  gym.city,
                                  style: AppTypography.body.copyWith(
                                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Address
                      _DetailSection(
                        icon: Icons.location_on,
                        title: 'Address',
                        child: Text(
                          gym.fullAddress,
                          style: AppTypography.body,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Phone
                      if (gym.phone != null)
                        _DetailSection(
                          icon: Icons.phone,
                          title: 'Phone',
                          child: InkWell(
                            onTap: () {
                              // TODO: Launch phone dialer
                            },
                            child: Text(
                              gym.phone!,
                              style: AppTypography.body.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      if (gym.phone != null) const SizedBox(height: AppSpacing.md),

                      // Occupancy
                      _DetailSection(
                        icon: Icons.people,
                        title: 'Current Occupancy',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _OccupancyBadge(gym: gym),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${gym.currentOccupancy} / ${gym.capacity}',
                                  style: AppTypography.body,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: AppSpacing.borderRadiusSm,
                              child: LinearProgressIndicator(
                                value: gym.occupancyPercentage,
                                minHeight: 8,
                                backgroundColor: context.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getOccupancyColor(gym.occupancyStatus),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Operating hours
                      _DetailSection(
                        icon: Icons.access_time,
                        title: 'Operating Hours',
                        child: _OperatingHoursWidget(gym: gym),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Amenities
                      if (gym.amenities != null && gym.amenities!.isNotEmpty)
                        _DetailSection(
                          icon: Icons.fitness_center,
                          title: 'Amenities',
                          child: Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: gym.amenities!
                                .map((amenity) => _AmenityChip(amenity: amenity))
                                .toList(),
                          ),
                        ),
                      if (gym.amenities != null && gym.amenities!.isNotEmpty)
                        const SizedBox(height: AppSpacing.md),

                      // Map button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: gym.latitude != null && gym.longitude != null
                              ? () async {
                                  final success = await URLLauncherHelper.openInMaps(
                                    gym.latitude!,
                                    gym.longitude!,
                                    label: gym.name,
                                  );
                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to open maps'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.map),
                          label: Text(
                            gym.latitude != null && gym.longitude != null
                                ? 'Open in Maps'
                                : 'Location not available',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: const Icon(
        Icons.fitness_center,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  Color _getOccupancyColor(OccupancyStatus status) {
    switch (status) {
      case OccupancyStatus.notBusy:
        return Colors.green;
      case OccupancyStatus.moderate:
        return Colors.orange;
      case OccupancyStatus.busy:
        return Colors.deepOrange;
      case OccupancyStatus.full:
        return Colors.red;
    }
  }
}

/// Detail section widget.
class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: child,
        ),
      ],
    );
  }
}

/// Operating hours widget.
class _OperatingHoursWidget extends StatelessWidget {
  final GymModel gym;

  const _OperatingHoursWidget({required this.gym});

  @override
  Widget build(BuildContext context) {
    if (gym.is24Hours) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 16,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              'Open 24 Hours',
              style: AppTypography.body.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (gym.operatingHours == null) {
      return Text(
        'Hours not available',
        style: AppTypography.body.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    return Column(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final dayLabel = dayLabels[index];
        final hours = gym.operatingHours![day];
        final isToday = index == todayIndex;

        String hoursText;
        if (hours == null) {
          hoursText = 'Closed';
        } else {
          final open = hours['open'] as String?;
          final close = hours['close'] as String?;
          if (open == null || close == null) {
            hoursText = 'Closed';
          } else {
            hoursText = '$open - $close';
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  dayLabel,
                  style: AppTypography.body.copyWith(
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                    color: isToday ? AppColors.primary : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                hoursText,
                style: AppTypography.body.copyWith(
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  color: isToday ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
