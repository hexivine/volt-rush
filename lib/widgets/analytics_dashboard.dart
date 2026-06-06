import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Analytics dashboard with multiple widget components.
/// Provides comprehensive game statistics and tracking.

/// Shows daily game statistics
class DailyStatsWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const DailyStatsWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<DailyStatsWidget> createState() => _DailyStatsWidgetState();
}

class _DailyStatsWidgetState extends State<DailyStatsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'DailyStats'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DailyStats',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekly progress tracker
class WeeklyProgressWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const WeeklyProgressWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<WeeklyProgressWidget> createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<WeeklyProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'WeeklyProgress'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WeeklyProgress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Monthly performance report
class MonthlyReportWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const MonthlyReportWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<MonthlyReportWidget> createState() => _MonthlyReportWidgetState();
}

class _MonthlyReportWidgetState extends State<MonthlyReportWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'MonthlyReport'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MonthlyReport',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tracks winning streaks
class StreakTrackerWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const StreakTrackerWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<StreakTrackerWidget> createState() => _StreakTrackerWidgetState();
}

class _StreakTrackerWidgetState extends State<StreakTrackerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'StreakTracker'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'StreakTracker',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Historical score chart
class ScoreHistoryWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const ScoreHistoryWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<ScoreHistoryWidget> createState() => _ScoreHistoryWidgetState();
}

class _ScoreHistoryWidgetState extends State<ScoreHistoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'ScoreHistory'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ScoreHistory',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of achievements
class AchievementGridWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const AchievementGridWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<AchievementGridWidget> createState() => _AchievementGridWidgetState();
}

class _AchievementGridWidgetState extends State<AchievementGridWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'AchievementGrid'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AchievementGrid',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact leaderboard view
class LeaderboardCardWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const LeaderboardCardWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<LeaderboardCardWidget> createState() => _LeaderboardCardWidgetState();
}

class _LeaderboardCardWidgetState extends State<LeaderboardCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'LeaderboardCard'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LeaderboardCard',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Countdown timer widget
class GameTimerWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const GameTimerWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<GameTimerWidget> createState() => _GameTimerWidgetState();
}

class _GameTimerWidgetState extends State<GameTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'GameTimer'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GameTimer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows active power-ups
class PowerUpIndicatorWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const PowerUpIndicatorWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<PowerUpIndicatorWidget> createState() => _PowerUpIndicatorWidgetState();
}

class _PowerUpIndicatorWidgetState extends State<PowerUpIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'PowerUpIndicator'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PowerUpIndicator',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays combo multiplier
class ComboMeterWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const ComboMeterWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<ComboMeterWidget> createState() => _ComboMeterWidgetState();
}

class _ComboMeterWidgetState extends State<ComboMeterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'ComboMeter'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ComboMeter',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Player health indicator
class HealthBarWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const HealthBarWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<HealthBarWidget> createState() => _HealthBarWidgetState();
}

class _HealthBarWidgetState extends State<HealthBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'HealthBar'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HealthBar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Experience points bar
class XPProgressWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const XPProgressWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<XPProgressWidget> createState() => _XPProgressWidgetState();
}

class _XPProgressWidgetState extends State<XPProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'XPProgress'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'XPProgress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Current level display
class LevelBadgeWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const LevelBadgeWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<LevelBadgeWidget> createState() => _LevelBadgeWidgetState();
}

class _LevelBadgeWidgetState extends State<LevelBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'LevelBadge'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LevelBadge',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// In-game currency display
class CoinCounterWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const CoinCounterWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<CoinCounterWidget> createState() => _CoinCounterWidgetState();
}

class _CoinCounterWidgetState extends State<CoinCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'CoinCounter'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CoinCounter',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Alert notifications
class NotificationBellWidget extends StatefulWidget {
  final String playerId;
  final bool showDetails;
  final VoidCallback? onTap;

  const NotificationBellWidget({
    super.key,
    required this.playerId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<NotificationBellWidget> createState() => _NotificationBellWidgetState();
}

class _NotificationBellWidgetState extends State<NotificationBellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _data = {'value': 42, 'label': 'NotificationBell'};
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NotificationBell',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_data?['value'] ?? 0}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Text(
                  'Player: ${widget.playerId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
