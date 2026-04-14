import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reports_provider.dart';
import 'widgets/average_intake_card.dart';
import 'widgets/macro_pie_chart.dart';
import 'widgets/nutrient_bar_chart.dart';
import 'widgets/nutrient_line_chart.dart';
import 'widgets/streak_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _weeklyKey = GlobalKey();
  final _monthlyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadData();
    }
  }

  String? get _userId => context.read<AuthProvider>().userModel?.uid;

  void _loadData() {
    final uid = _userId;
    if (uid == null) return;
    final provider = context.read<ReportsProvider>();
    if (_tabController.index == 0) {
      provider.loadWeeklyData(uid);
    } else {
      provider.loadMonthlyData(uid);
    }
  }

  Future<void> _export() async {
    final key = _tabController.index == 0 ? _weeklyKey : _monthlyKey;
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'image/png', name: 'report.png')],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(l10n),
          Expanded(
            child: Consumer<ReportsProvider>(
              builder: (context, provider, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeeklyTab(provider, l10n),
                    _buildMonthlyTab(provider, l10n),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header matching the meal planner header pattern ───
  Widget _buildHeader(AppLocalizations l10n) {
    final provider = context.watch<ReportsProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        boxShadow: [AppTheme.shadowOf(context)],
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              // Row 1: Back + icon badge + title + export
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppTheme.textPrimaryOf(context),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.dinnerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: AppTheme.dinnerColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.reports,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.ios_share_outlined, size: 20),
                    onPressed: _export,
                    color: AppTheme.textSecondaryOf(context),
                    tooltip: l10n.exportAsImage,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Week/Month navigation with day indicators
              if (_tabController.index == 0)
                _buildWeekNav(provider)
              else
                _buildMonthNav(provider),
              const SizedBox(height: 10),
              // Row 3: Date range text
              Text(
                _tabController.index == 0
                    ? '${DateFormat('MMM d').format(provider.weekStart)} – ${DateFormat('MMM d, yyyy').format(provider.weekEnd)}'
                    : DateFormat('MMMM yyyy').format(provider.selectedMonth),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryOf(context),
                    ),
              ),
              const SizedBox(height: 4),
              // Tab bar
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textTertiaryOf(context),
                indicatorColor: AppTheme.primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: l10n.weekly),
                  Tab(text: l10n.monthly),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Week navigation row with 7 day circles (matching meal planner) ───
  Widget _buildWeekNav(ReportsProvider provider) {
    final weekStart = provider.weekStart;
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final hasData = <int, bool>{};

    for (int i = 0; i < 7 && i < provider.dailySummaries.length; i++) {
      hasData[i] = provider.dailySummaries[i].totalCalories > 0;
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            provider.previousWeek();
            _loadData();
          },
          child: Icon(
            Icons.chevron_left,
            color: AppTheme.textSecondaryOf(context),
            size: 22,
          ),
        ),
        ...List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isFilled = hasData[i] == true;
          final now = DateTime.now();
          final isToday = day.year == now.year &&
              day.month == now.month &&
              day.day == now.day;

          return Expanded(
            child: Column(
              children: [
                Text(
                  dayLetters[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFilled || isToday
                        ? AppTheme.primaryColor
                        : AppTheme.textTertiaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? AppTheme.primaryColor
                        : isFilled
                            ? AppTheme.dinnerColor
                            : Colors.transparent,
                    border: !isToday && !isFilled
                        ? Border.all(
                            color: AppTheme.neutralLightOf(context),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: isFilled && !isToday
                        ? const Icon(Icons.check,
                            size: 15, color: Colors.white)
                        : Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday || isFilled
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isToday || isFilled
                                  ? Colors.white
                                  : AppTheme.textPrimaryOf(context),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 3),
                if (isToday)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 5),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: () {
            provider.nextWeek();
            _loadData();
          },
          child: Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondaryOf(context),
            size: 22,
          ),
        ),
      ],
    );
  }

  // ─── Month navigation row ───
  Widget _buildMonthNav(ReportsProvider provider) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;
    final daysWithData = provider.dailySummaries
        .where((s) => s.totalCalories > 0)
        .length;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            provider.previousMonth();
            _loadData();
          },
          child: Icon(
            Icons.chevron_left,
            color: AppTheme.textSecondaryOf(context),
            size: 22,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              // Progress bar showing days tracked
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.neutralLightOf(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = daysInMonth > 0
                        ? (daysWithData / daysInMonth).clamp(0.0, 1.0)
                        : 0.0;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: AppTheme.dinnerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$daysWithData / $daysInMonth days tracked',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiaryOf(context),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            provider.nextMonth();
            _loadData();
          },
          child: Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondaryOf(context),
            size: 22,
          ),
        ),
      ],
    );
  }

  // ─── Weekly tab ───
  Widget _buildWeeklyTab(ReportsProvider provider, AppLocalizations l10n) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RepaintBoundary(
      key: _weeklyKey,
      child: Container(
        color: AppTheme.backgroundOf(context),
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          children: [
            NutrientBarChart(
              summaries: provider.dailySummaries,
              selectedNutrient: provider.selectedNutrient,
              onNutrientChanged: (type) => provider.setSelectedNutrient(type),
            ),
            const SizedBox(height: 12),
            AverageIntakeCard(averages: provider.calculateAverages()),
            const SizedBox(height: 12),
            StreakCard(streak: provider.streak),
          ],
        ),
      ),
    );
  }

  // ─── Monthly tab ───
  Widget _buildMonthlyTab(ReportsProvider provider, AppLocalizations l10n) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RepaintBoundary(
      key: _monthlyKey,
      child: Container(
        color: AppTheme.backgroundOf(context),
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          children: [
            NutrientLineChart(summaries: provider.dailySummaries),
            const SizedBox(height: 12),
            MacroPieChart(
              distribution: provider.calculateMacroDistribution(),
            ),
            const SizedBox(height: 12),
            AverageIntakeCard(averages: provider.calculateAverages()),
          ],
        ),
      ),
    );
  }
}
