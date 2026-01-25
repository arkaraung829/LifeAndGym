import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/providers/safe_change_notifier.dart';
import '../../../core/services/logger_service.dart';
import '../models/gym_model.dart';
import '../services/gym_service.dart';

/// Provider state for gyms.
enum GymState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for gym-related operations.
class GymProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final GymService _gymService;

  GymProvider({GymService? gymService})
      : _gymService = gymService ?? GymService();

  // State
  GymState _state = GymState.initial;
  List<GymModel> _gyms = [];
  GymModel? _selectedGym;
  String? _error;
  StreamSubscription? _occupancySubscription;

  // Getters
  GymState get state => _state;
  List<GymModel> get gyms => _gyms;
  GymModel? get selectedGym => _selectedGym;
  String? get error => _error;
  bool get isLoading => _state == GymState.loading;
  bool get hasGyms => _gyms.isNotEmpty;

  /// Load all gyms.
  Future<void> loadGyms() async {
    _setState(GymState.loading);

    try {
      _gyms = await _gymService.getAllGyms();
      _setState(GymState.loaded);
      AppLogger.info('Loaded ${_gyms.length} gyms');
    } catch (e) {
      _setError('Failed to load gyms: ${e.toString()}');
      AppLogger.error('Failed to load gyms', error: e);
    }
  }

  /// Load gym by ID.
  Future<void> loadGymById(String gymId) async {
    _setState(GymState.loading);

    try {
      _selectedGym = await _gymService.getGymById(gymId);
      _setState(GymState.loaded);
      AppLogger.info('Loaded gym: ${_selectedGym!.name}');
    } catch (e) {
      _setError('Failed to load gym: ${e.toString()}');
      AppLogger.error('Failed to load gym', error: e);
    }
  }

  /// Search gyms.
  Future<void> searchGyms(String query) async {
    if (query.isEmpty) {
      await loadGyms();
      return;
    }

    _setState(GymState.loading);

    try {
      _gyms = await _gymService.searchGyms(query);
      _setState(GymState.loaded);
      AppLogger.info('Found ${_gyms.length} gyms matching "$query"');
    } catch (e) {
      _setError('Failed to search gyms: ${e.toString()}');
      AppLogger.error('Failed to search gyms', error: e);
    }
  }

  /// Get nearby gyms.
  Future<void> getNearbyGyms(double latitude, double longitude) async {
    _setState(GymState.loading);

    try {
      _gyms = await _gymService.getNearbyGyms(
        latitude: latitude,
        longitude: longitude,
      );
      _setState(GymState.loaded);
      AppLogger.info('Found ${_gyms.length} nearby gyms');
    } catch (e) {
      _setError('Failed to find nearby gyms: ${e.toString()}');
      AppLogger.error('Failed to find nearby gyms', error: e);
    }
  }

  /// Select a gym.
  void selectGym(GymModel gym) {
    _selectedGym = gym;
    safeNotifyListeners();

    // Start streaming occupancy updates
    _startOccupancyStream(gym.id);
  }

  /// Clear selected gym.
  void clearSelectedGym() {
    _selectedGym = null;
    _stopOccupancyStream();
    safeNotifyListeners();
  }

  /// Start streaming occupancy updates for a gym.
  void _startOccupancyStream(String gymId) {
    _stopOccupancyStream();

    _occupancySubscription = _gymService
        .streamGymOccupancy(gymId)
        .listen(
          (gym) {
            if (_selectedGym?.id == gym.id) {
              _selectedGym = gym;
              safeNotifyListeners();
            }
          },
          onError: (error) {
            AppLogger.error('Occupancy stream error', error: error);
          },
        );
  }

  /// Stop streaming occupancy updates.
  void _stopOccupancyStream() {
    _occupancySubscription?.cancel();
    _occupancySubscription = null;
  }

  /// Clear error.
  void clearError() {
    _error = null;
    if (_state == GymState.error) {
      _state = _gyms.isNotEmpty ? GymState.loaded : GymState.initial;
    }
    safeNotifyListeners();
  }

  // Private helpers
  void _setState(GymState newState) {
    _state = newState;
    _error = null;
    safeNotifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = GymState.error;
    safeNotifyListeners();
  }

  @override
  void dispose() {
    _stopOccupancyStream();
    super.dispose();
  }
}
