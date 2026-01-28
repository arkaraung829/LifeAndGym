import 'package:flutter/material.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../core/providers/safe_change_notifier.dart';
import '../models/body_metrics_model.dart';
import '../services/body_metrics_service.dart';

/// State for body metrics operations.
enum BodyMetricsState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for managing body metrics state and operations.
class BodyMetricsProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final BodyMetricsService _bodyMetricsService;

  BodyMetricsProvider({BodyMetricsService? bodyMetricsService})
      : _bodyMetricsService = bodyMetricsService ?? BodyMetricsService();

  // State
  BodyMetricsState _state = BodyMetricsState.initial;
  String? _errorMessage;

  // Metrics data
  List<BodyMetricsModel> _metrics = [];
  BodyMetricsModel? _latestMetrics;
  Map<String, dynamic>? _trends;

  // Getters
  BodyMetricsState get state => _state;
  String? get errorMessage => _errorMessage;
  List<BodyMetricsModel> get metrics => _metrics;
  BodyMetricsModel? get latestMetrics => _latestMetrics;
  Map<String, dynamic>? get trends => _trends;

  // Computed properties
  bool get isLoading => _state == BodyMetricsState.loading;
  bool get hasError => _state == BodyMetricsState.error;

  // ==================== METRICS ====================

  /// Load body metrics for a user.
  Future<void> loadMetrics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _state = BodyMetricsState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      _metrics = await _bodyMetricsService.getMetrics(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Set latest metrics (most recent entry)
      if (_metrics.isNotEmpty) {
        _latestMetrics = _metrics.reduce((a, b) =>
            a.recordedAt.isAfter(b.recordedAt) ? a : b);
      } else {
        _latestMetrics = null;
      }

      _state = BodyMetricsState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    }
  }

  /// Add a new body metrics entry.
  Future<void> addEntry(BodyMetricsModel metrics) async {
    try {
      _state = BodyMetricsState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      final entry = await _bodyMetricsService.createEntry(metrics);

      // Add to local list and update latest
      _metrics.add(entry);
      if (_latestMetrics == null ||
          entry.recordedAt.isAfter(_latestMetrics!.recordedAt)) {
        _latestMetrics = entry;
      }

      _state = BodyMetricsState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    }
  }

  /// Update an existing body metrics entry.
  Future<void> updateEntry(String id, BodyMetricsModel metrics) async {
    try {
      _state = BodyMetricsState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      final updatedEntry = await _bodyMetricsService.updateEntry(id, metrics);

      // Update in local list
      final index = _metrics.indexWhere((m) => m.id == id);
      if (index != -1) {
        _metrics[index] = updatedEntry;

        // Update latest if this was the latest entry
        if (_latestMetrics?.id == id) {
          _latestMetrics = updatedEntry;
        } else {
          // Recalculate latest in case dates changed
          _latestMetrics = _metrics.reduce((a, b) =>
              a.recordedAt.isAfter(b.recordedAt) ? a : b);
        }
      }

      _state = BodyMetricsState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    }
  }

  /// Delete a body metrics entry.
  Future<void> deleteEntry(String id) async {
    try {
      _state = BodyMetricsState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      await _bodyMetricsService.deleteEntry(id);

      // Remove from local list
      _metrics.removeWhere((m) => m.id == id);

      // Update latest if we deleted the latest entry
      if (_latestMetrics?.id == id) {
        if (_metrics.isNotEmpty) {
          _latestMetrics = _metrics.reduce((a, b) =>
              a.recordedAt.isAfter(b.recordedAt) ? a : b);
        } else {
          _latestMetrics = null;
        }
      }

      _state = BodyMetricsState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = BodyMetricsState.error;
      safeNotifyListeners();
    }
  }

  /// Load trends data for body metrics.
  Future<void> loadTrends(String userId, {int days = 30}) async {
    try {
      _trends = await _bodyMetricsService.getTrends(userId, days: days);
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      // Don't set error state for trends - it's non-critical
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      // Don't set error state for trends - it's non-critical
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      // Don't set error state for trends - it's non-critical
      safeNotifyListeners();
    }
  }

  /// Reset provider state.
  void reset() {
    _state = BodyMetricsState.initial;
    _errorMessage = null;
    _metrics = [];
    _latestMetrics = null;
    _trends = null;
    safeNotifyListeners();
  }
}
