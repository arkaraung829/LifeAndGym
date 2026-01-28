import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

import '../services/logger_service.dart';

/// Helper class for launching URLs, phone numbers, and emails.
///
/// Provides utility methods to open external applications like
/// email clients, phone dialers, and web browsers.
class URLLauncherHelper {
  URLLauncherHelper._();

  /// Launches an email client with the specified email address.
  ///
  /// Optionally includes a subject line and email body.
  /// Returns true if the email client was successfully launched.
  ///
  /// Example:
  /// ```dart
  /// await URLLauncherHelper.launchEmail(
  ///   'support@example.com',
  ///   subject: 'Help Request',
  ///   body: 'I need assistance with...',
  /// );
  /// ```
  static Future<bool> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      AppLogger.info('Attempting to launch email: $email', tag: 'URLLauncher');

      // Build mailto URL with optional subject and body
      final buffer = StringBuffer('mailto:$email');
      final params = <String>[];

      if (subject != null && subject.isNotEmpty) {
        params.add('subject=${Uri.encodeComponent(subject)}');
      }

      if (body != null && body.isNotEmpty) {
        params.add('body=${Uri.encodeComponent(body)}');
      }

      if (params.isNotEmpty) {
        buffer.write('?${params.join('&')}');
      }

      final uri = Uri.parse(buffer.toString());

      // Check if email client is available
      if (!await canLaunchUrl(uri)) {
        AppLogger.warning('No email client available', tag: 'URLLauncher');
        await _showError('No email client found. Please install an email app.');
        return false;
      }

      // Launch email client
      final success = await launchUrl(uri);
      if (success) {
        AppLogger.info('Email client launched successfully', tag: 'URLLauncher');
      } else {
        AppLogger.warning('Failed to launch email client', tag: 'URLLauncher');
        await _showError('Failed to open email client.');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error launching email',
        tag: 'URLLauncher',
        error: e,
        stackTrace: stackTrace,
      );
      await _showError('An error occurred while opening email client.');
      return false;
    }
  }

  /// Launches the phone dialer with the specified phone number.
  ///
  /// Automatically removes common formatting characters like spaces,
  /// dashes, and parentheses before launching.
  /// Returns true if the dialer was successfully launched.
  ///
  /// Example:
  /// ```dart
  /// await URLLauncherHelper.launchPhone('+1 (555) 123-4567');
  /// ```
  static Future<bool> launchPhone(String phoneNumber) async {
    try {
      AppLogger.info('Attempting to launch phone: $phoneNumber', tag: 'URLLauncher');

      // Remove formatting characters
      final cleanedNumber = phoneNumber
          .replaceAll(' ', '')
          .replaceAll('-', '')
          .replaceAll('(', '')
          .replaceAll(')', '');

      final uri = Uri.parse('tel:$cleanedNumber');

      // Check if phone dialer is available
      if (!await canLaunchUrl(uri)) {
        AppLogger.warning('No phone dialer available', tag: 'URLLauncher');
        await _showError('No phone dialer found on this device.');
        return false;
      }

      // Launch phone dialer
      final success = await launchUrl(uri);
      if (success) {
        AppLogger.info('Phone dialer launched successfully', tag: 'URLLauncher');
      } else {
        AppLogger.warning('Failed to launch phone dialer', tag: 'URLLauncher');
        await _showError('Failed to open phone dialer.');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error launching phone',
        tag: 'URLLauncher',
        error: e,
        stackTrace: stackTrace,
      );
      await _showError('An error occurred while opening phone dialer.');
      return false;
    }
  }

  /// Opens the specified coordinates in a map application.
  ///
  /// Shows a list of available map apps if multiple are installed.
  /// If only one map app is available, opens it directly.
  /// Falls back to Google Maps web if no map apps are available.
  /// Returns true if a map was successfully launched.
  ///
  /// Example:
  /// ```dart
  /// await URLLauncherHelper.openInMaps(
  ///   37.7749,
  ///   -122.4194,
  ///   label: 'San Francisco Gym',
  /// );
  /// ```
  static Future<bool> openInMaps(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    try {
      AppLogger.info(
        'Attempting to open maps at: $latitude, $longitude',
        tag: 'URLLauncher',
      );

      // Check if any map apps are available
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isEmpty) {
        // Fallback to Google Maps web URL
        AppLogger.warning(
          'No map apps installed, falling back to web',
          tag: 'URLLauncher',
        );
        final webUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        return await launchURL(webUrl);
      }

      final coords = Coords(latitude, longitude);

      // If only one map is available, open it directly
      if (availableMaps.length == 1) {
        AppLogger.info(
          'Opening ${availableMaps.first.mapName}',
          tag: 'URLLauncher',
        );
        await availableMaps.first.showMarker(
          coords: coords,
          title: label ?? 'Location',
        );
        return true;
      }

      // Multiple maps available - let user choose
      // Note: MapLauncher.showMarker() handles the selection dialog internally
      AppLogger.info(
        'Showing map selection dialog (${availableMaps.length} apps available)',
        tag: 'URLLauncher',
      );

      await MapLauncher.showMarker(
        mapType: MapType.google, // Default preference
        coords: coords,
        title: label ?? 'Location',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error opening maps',
        tag: 'URLLauncher',
        error: e,
        stackTrace: stackTrace,
      );

      // Try fallback to web URL
      try {
        final webUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        AppLogger.info('Attempting fallback to web URL', tag: 'URLLauncher');
        return await launchURL(webUrl);
      } catch (fallbackError) {
        AppLogger.error(
          'Fallback to web URL also failed',
          tag: 'URLLauncher',
          error: fallbackError,
        );
        await _showError('Failed to open maps application.');
        return false;
      }
    }
  }

  /// Launches a URL in the external browser.
  ///
  /// Automatically adds https:// if the URL doesn't have a scheme.
  /// Returns true if the browser was successfully launched.
  ///
  /// Example:
  /// ```dart
  /// await URLLauncherHelper.launchURL('https://example.com');
  /// await URLLauncherHelper.launchURL('example.com'); // Adds https://
  /// ```
  static Future<bool> launchURL(String url) async {
    try {
      AppLogger.info('Attempting to launch URL: $url', tag: 'URLLauncher');

      // Add https:// if no scheme is present
      String validatedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        validatedUrl = 'https://$url';
        AppLogger.debug('Added https:// scheme to URL: $validatedUrl', tag: 'URLLauncher');
      }

      final uri = Uri.parse(validatedUrl);

      // Check if browser is available
      if (!await canLaunchUrl(uri)) {
        AppLogger.warning('Cannot launch URL: $validatedUrl', tag: 'URLLauncher');
        await _showError('Unable to open this URL.');
        return false;
      }

      // Launch URL in external browser
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (success) {
        AppLogger.info('URL launched successfully', tag: 'URLLauncher');
      } else {
        AppLogger.warning('Failed to launch URL', tag: 'URLLauncher');
        await _showError('Failed to open browser.');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error launching URL',
        tag: 'URLLauncher',
        error: e,
        stackTrace: stackTrace,
      );
      await _showError('An error occurred while opening the URL.');
      return false;
    }
  }

  /// Internal helper to show error messages.
  ///
  /// Currently just logs the error. In the future, this could show
  /// a snackbar or dialog when a BuildContext is available.
  static Future<void> _showError(String message) async {
    AppLogger.error(message, tag: 'URLLauncher');
    // TODO: Show snackbar or dialog when BuildContext is available
  }
}
