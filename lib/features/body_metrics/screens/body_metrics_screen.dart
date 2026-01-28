import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/body_metrics_provider.dart';
import '../models/body_metrics_model.dart';

/// Body metrics screen for tracking measurements.
class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final metricsProvider = context.read<BodyMetricsProvider>();
    await Future.wait([
      metricsProvider.loadMetrics(authProvider.user!.id),
      metricsProvider.loadTrends(authProvider.user!.id, days: _selectedDays),
    ]);
  }

  Future<void> _refreshTrends() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final metricsProvider = context.read<BodyMetricsProvider>();
    await metricsProvider.loadTrends(authProvider.user!.id, days: _selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Metrics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'History'),
          ],
          labelStyle: AppTypography.labelLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<BodyMetricsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.metrics.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.hasError) {
            return _buildErrorView(provider.errorMessage);
          }

          if (provider.metrics.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider),
              _buildTrendsTab(provider),
              _buildHistoryTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            AppSpacing.vGapLg,
            Text(
              'No metrics yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            AppSpacing.vGapMd,
            Text(
              'Track your first measurement!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapLg,
            FilledButton.icon(
              onPressed: () => _showAddEntryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Log Your First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String? errorMessage) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            AppSpacing.vGapMd,
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            AppSpacing.vGapSm,
            Text(
              errorMessage ?? 'Something went wrong',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapLg,
            FilledButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BodyMetricsProvider provider) {
    final latest = provider.latestMetrics;
    if (latest == null) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLatestMetricsCard(latest),
            AppSpacing.vGapMd,
            _buildQuickStatsRow(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestMetricsCard(BodyMetricsModel metrics) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Metrics',
                style: AppTypography.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(metrics.recordedAt),
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          if (metrics.weight != null) ...[
            _buildMetricRow(
              icon: Icons.monitor_weight,
              label: 'Weight',
              value: '${metrics.weight!.toStringAsFixed(1)} ${metrics.weightUnit}',
              color: AppColors.primary,
            ),
            AppSpacing.vGapSm,
          ],
          if (metrics.bmi != null) ...[
            _buildMetricRow(
              icon: Icons.insights,
              label: 'BMI',
              value: metrics.bmi!.toStringAsFixed(1),
              color: _getBMIColor(metrics.bmi!),
              trailing: _buildBMIBadge(metrics.bmiCategory),
            ),
            AppSpacing.vGapSm,
          ],
          if (metrics.bodyFat != null) ...[
            _buildMetricRow(
              icon: Icons.percent,
              label: 'Body Fat',
              value: '${metrics.bodyFat!.toStringAsFixed(1)}%',
              color: AppColors.warning,
            ),
            AppSpacing.vGapSm,
          ],
          if (metrics.muscleMass != null) ...[
            _buildMetricRow(
              icon: Icons.fitness_center,
              label: 'Muscle Mass',
              value: '${metrics.muscleMass!.toStringAsFixed(1)} ${metrics.weightUnit}',
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: AppTypography.heading4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildBMIBadge(String category) {
    Color color;
    switch (category) {
      case 'Normal':
        color = AppColors.success;
        break;
      case 'Overweight':
        color = AppColors.warning;
        break;
      case 'Obese':
        color = AppColors.error;
        break;
      case 'Underweight':
        color = AppColors.info;
        break;
      default:
        color = AppColors.onSurfaceDimDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        category,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildQuickStatsRow(BodyMetricsProvider provider) {
    final totalEntries = provider.metrics.length;
    final firstEntry = provider.metrics.reduce((a, b) => a.recordedAt.isBefore(b.recordedAt) ? a : b);
    final daysSinceFirst = DateTime.now().difference(firstEntry.recordedAt).inDays;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.assessment,
            label: 'Total Entries',
            value: totalEntries.toString(),
            color: AppColors.primary,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            label: 'Days Tracked',
            value: daysSinceFirst.toString(),
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          AppSpacing.vGapSm,
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BodyMetricsProvider provider) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          AppSpacing.vGapMd,
          _buildWeightChart(provider),
          AppSpacing.vGapMd,
          _buildBodyFatChart(provider),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTimeRangeChip('7 days', 7),
          AppSpacing.hGapSm,
          _buildTimeRangeChip('30 days', 30),
          AppSpacing.hGapSm,
          _buildTimeRangeChip('90 days', 90),
          AppSpacing.hGapSm,
          _buildTimeRangeChip('All', 365),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(String label, int days) {
    final isSelected = _selectedDays == days;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDays = days;
        });
        _refreshTrends();
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildWeightChart(BodyMetricsProvider provider) {
    final weightData = _getWeightData(provider);

    if (weightData.isEmpty) {
      return _buildNoChartData('No weight data available');
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Trend',
            style: AppTypography.heading3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapMd,
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: AppTypography.labelSmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= weightData.length) return const Text('');
                        final date = weightData[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('M/d').format(date),
                            style: AppTypography.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
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
  }

  Widget _buildBodyFatChart(BodyMetricsProvider provider) {
    final bodyFatData = _getBodyFatData(provider);

    if (bodyFatData.isEmpty) {
      return _buildNoChartData('No body fat data available');
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Fat Trend',
            style: AppTypography.heading3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapMd,
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(0)}%',
                          style: AppTypography.labelSmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= bodyFatData.length) return const Text('');
                        final date = bodyFatData[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('M/d').format(date),
                            style: AppTypography.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: bodyFatData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                        .toList(),
                    isCurved: true,
                    color: AppColors.warning,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.warning.withValues(alpha: 0.3),
                          AppColors.warning.withValues(alpha: 0.0),
                        ],
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
  }

  Widget _buildNoChartData(String message) {
    return CardContainer(
      child: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text(
            message,
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  List<_ChartDataPoint> _getWeightData(BodyMetricsProvider provider) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _selectedDays));

    final filteredMetrics = provider.metrics
        .where((m) => m.weight != null && m.recordedAt.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return filteredMetrics
        .map((m) => _ChartDataPoint(date: m.recordedAt, value: m.weight!))
        .toList();
  }

  List<_ChartDataPoint> _getBodyFatData(BodyMetricsProvider provider) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _selectedDays));

    final filteredMetrics = provider.metrics
        .where((m) => m.bodyFat != null && m.recordedAt.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return filteredMetrics
        .map((m) => _ChartDataPoint(date: m.recordedAt, value: m.bodyFat!))
        .toList();
  }

  Widget _buildHistoryTab(BodyMetricsProvider provider) {
    final sortedMetrics = List<BodyMetricsModel>.from(provider.metrics)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: sortedMetrics.length,
        itemBuilder: (context, index) {
          final metrics = sortedMetrics[index];
          return _buildHistoryCard(metrics);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BodyMetricsModel metrics) {
    return CardContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(metrics.recordedAt),
                style: AppTypography.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditEntryDialog(context, metrics),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  AppSpacing.hGapSm,
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                    onPressed: () => _deleteEntry(context, metrics.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vGapMd,
          if (metrics.weight != null)
            _buildHistoryItem('Weight', '${metrics.weight!.toStringAsFixed(1)} ${metrics.weightUnit}'),
          if (metrics.bmi != null)
            _buildHistoryItem('BMI', '${metrics.bmi!.toStringAsFixed(1)} (${metrics.bmiCategory})'),
          if (metrics.bodyFat != null)
            _buildHistoryItem('Body Fat', '${metrics.bodyFat!.toStringAsFixed(1)}%'),
          if (metrics.muscleMass != null)
            _buildHistoryItem('Muscle Mass', '${metrics.muscleMass!.toStringAsFixed(1)} ${metrics.weightUnit}'),
          if (metrics.measurements != null && metrics.measurements!.isNotEmpty) ...[
            AppSpacing.vGapSm,
            Text(
              'Measurements:',
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            ...metrics.measurements!.entries.map(
              (e) => _buildHistoryItem(
                _formatMeasurementName(e.key),
                '${e.value.toStringAsFixed(1)} cm',
              ),
            ),
          ],
          if (metrics.notes != null && metrics.notes!.isNotEmpty) ...[
            AppSpacing.vGapSm,
            Text(
              'Notes:',
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              metrics.notes!,
              style: AppTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMeasurementName(String key) {
    return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Future<void> _deleteEntry(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final provider = context.read<BodyMetricsProvider>();
      await provider.deleteEntry(id);

      if (!mounted) return;
      if (!provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
      }
    }
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _MetricsEntryDialog(),
    );
  }

  void _showEditEntryDialog(BuildContext context, BodyMetricsModel metrics) {
    showDialog(
      context: context,
      builder: (context) => _MetricsEntryDialog(existingMetrics: metrics),
    );
  }
}

class _ChartDataPoint {
  final DateTime date;
  final double value;

  _ChartDataPoint({required this.date, required this.value});
}

class _MetricsEntryDialog extends StatefulWidget {
  final BodyMetricsModel? existingMetrics;

  const _MetricsEntryDialog({this.existingMetrics});

  @override
  State<_MetricsEntryDialog> createState() => _MetricsEntryDialogState();
}

class _MetricsEntryDialogState extends State<_MetricsEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final _weightController = TextEditingController();
  String _weightUnit = 'kg';
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _bmiController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _armsController = TextEditingController();
  final _thighsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _showMeasurements = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existingMetrics?.recordedAt ?? DateTime.now();

    if (widget.existingMetrics != null) {
      final m = widget.existingMetrics!;
      if (m.weight != null) _weightController.text = m.weight!.toStringAsFixed(1);
      _weightUnit = m.weightUnit;
      if (m.bodyFat != null) _bodyFatController.text = m.bodyFat!.toStringAsFixed(1);
      if (m.muscleMass != null) _muscleMassController.text = m.muscleMass!.toStringAsFixed(1);
      if (m.bmi != null) _bmiController.text = m.bmi!.toStringAsFixed(1);
      if (m.notes != null) _notesController.text = m.notes!;

      if (m.measurements != null) {
        _showMeasurements = true;
        if (m.measurements!['chest'] != null) _chestController.text = m.measurements!['chest']!.toStringAsFixed(1);
        if (m.measurements!['waist'] != null) _waistController.text = m.measurements!['waist']!.toStringAsFixed(1);
        if (m.measurements!['hips'] != null) _hipsController.text = m.measurements!['hips']!.toStringAsFixed(1);
        if (m.measurements!['arms'] != null) _armsController.text = m.measurements!['arms']!.toStringAsFixed(1);
        if (m.measurements!['thighs'] != null) _thighsController.text = m.measurements!['thighs']!.toStringAsFixed(1);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _bmiController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _armsController.dispose();
    _thighsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingMetrics == null ? 'Add Entry' : 'Edit Entry'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              AppSpacing.vGapMd,
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _weightUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _weightUnit = value ?? 'kg';
                        });
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              TextFormField(
                controller: _bmiController,
                decoration: const InputDecoration(
                  labelText: 'BMI',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              ),
              AppSpacing.vGapMd,
              TextFormField(
                controller: _bodyFatController,
                decoration: const InputDecoration(
                  labelText: 'Body Fat %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final val = double.tryParse(value);
                    if (val == null || val < 0 || val > 100) {
                      return 'Must be between 0-100';
                    }
                  }
                  return null;
                },
              ),
              AppSpacing.vGapMd,
              TextFormField(
                controller: _muscleMassController,
                decoration: const InputDecoration(
                  labelText: 'Muscle Mass',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              ),
              AppSpacing.vGapMd,
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Add Measurements'),
                value: _showMeasurements,
                onChanged: (value) {
                  setState(() {
                    _showMeasurements = value ?? false;
                  });
                },
              ),
              if (_showMeasurements) ...[
                AppSpacing.vGapSm,
                TextFormField(
                  controller: _chestController,
                  decoration: const InputDecoration(
                    labelText: 'Chest (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
                AppSpacing.vGapSm,
                TextFormField(
                  controller: _waistController,
                  decoration: const InputDecoration(
                    labelText: 'Waist (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
                AppSpacing.vGapSm,
                TextFormField(
                  controller: _hipsController,
                  decoration: const InputDecoration(
                    labelText: 'Hips (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
                AppSpacing.vGapSm,
                TextFormField(
                  controller: _armsController,
                  decoration: const InputDecoration(
                    labelText: 'Arms (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
                AppSpacing.vGapSm,
                TextFormField(
                  controller: _thighsController,
                  decoration: const InputDecoration(
                    labelText: 'Thighs (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
              ],
              AppSpacing.vGapMd,
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveEntry,
          child: Text(widget.existingMetrics == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final measurements = <String, double>{};
    if (_showMeasurements) {
      if (_chestController.text.isNotEmpty) {
        measurements['chest'] = double.parse(_chestController.text);
      }
      if (_waistController.text.isNotEmpty) {
        measurements['waist'] = double.parse(_waistController.text);
      }
      if (_hipsController.text.isNotEmpty) {
        measurements['hips'] = double.parse(_hipsController.text);
      }
      if (_armsController.text.isNotEmpty) {
        measurements['arms'] = double.parse(_armsController.text);
      }
      if (_thighsController.text.isNotEmpty) {
        measurements['thighs'] = double.parse(_thighsController.text);
      }
    }

    final metrics = BodyMetricsModel(
      id: widget.existingMetrics?.id ?? '',
      userId: authProvider.user!.id,
      recordedAt: _selectedDate,
      weight: _weightController.text.isNotEmpty ? double.parse(_weightController.text) : null,
      weightUnit: _weightUnit,
      bodyFat: _bodyFatController.text.isNotEmpty ? double.parse(_bodyFatController.text) : null,
      muscleMass: _muscleMassController.text.isNotEmpty ? double.parse(_muscleMassController.text) : null,
      bmi: _bmiController.text.isNotEmpty ? double.parse(_bmiController.text) : null,
      measurements: measurements.isEmpty ? null : measurements,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.existingMetrics?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<BodyMetricsProvider>();

    if (widget.existingMetrics == null) {
      await provider.addEntry(metrics);
    } else {
      await provider.updateEntry(widget.existingMetrics!.id, metrics);
    }

    if (mounted) {
      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to save entry'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingMetrics == null ? 'Entry added' : 'Entry updated'),
          ),
        );
      }
    }
  }
}
