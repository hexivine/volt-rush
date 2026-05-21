"""Generate a large Dart analytics service file for testing."""

widgets = [
    ("DailyStats", "daily_stats", "Shows daily game statistics"),
    ("WeeklyProgress", "weekly_progress", "Weekly progress tracker"),
    ("MonthlyReport", "monthly_report", "Monthly performance report"),
    ("StreakTracker", "streak_tracker", "Tracks winning streaks"),
    ("ScoreHistory", "score_history", "Historical score chart"),
    ("AchievementGrid", "achievement_grid", "Grid of achievements"),
    ("LeaderboardCard", "leaderboard_card", "Compact leaderboard view"),
    ("GameTimer", "game_timer", "Countdown timer widget"),
    ("PowerUpIndicator", "power_up_indicator", "Shows active power-ups"),
    ("ComboMeter", "combo_meter", "Displays combo multiplier"),
    ("HealthBar", "health_bar", "Player health indicator"),
    ("XPProgress", "xp_progress", "Experience points bar"),
    ("LevelBadge", "level_badge", "Current level display"),
    ("CoinCounter", "coin_counter", "In-game currency display"),
    ("NotificationBell", "notification_bell", "Alert notifications"),
]

lines = [
    "import 'package:flutter/material.dart';",
    "import 'package:provider/provider.dart';",
    "",
    "/// Analytics dashboard with multiple widget components.",
    "/// Provides comprehensive game statistics and tracking.",
    "",
]

for class_name, file_name, desc in widgets:
    lines.append(f"/// {desc}")
    lines.append(f"class {class_name}Widget extends StatefulWidget {{")
    lines.append(f"  final String playerId;")
    lines.append(f"  final bool showDetails;")
    lines.append(f"  final VoidCallback? onTap;")
    lines.append(f"")
    lines.append(f"  const {class_name}Widget({{")
    lines.append(f"    super.key,")
    lines.append(f"    required this.playerId,")
    lines.append(f"    this.showDetails = false,")
    lines.append(f"    this.onTap,")
    lines.append(f"  }});")
    lines.append(f"")
    lines.append(f"  @override")
    lines.append(f"  State<{class_name}Widget> createState() => _{class_name}WidgetState();")
    lines.append(f"}}")
    lines.append(f"")
    lines.append(f"class _{class_name}WidgetState extends State<{class_name}Widget>")
    lines.append(f"    with SingleTickerProviderStateMixin {{")
    lines.append(f"  late AnimationController _controller;")
    lines.append(f"  late Animation<double> _fadeAnimation;")
    lines.append(f"  bool _isLoading = true;")
    lines.append(f"  Map<String, dynamic>? _data;")
    lines.append(f"  String? _error;")
    lines.append(f"")
    lines.append(f"  @override")
    lines.append(f"  void initState() {{")
    lines.append(f"    super.initState();")
    lines.append(f"    _controller = AnimationController(")
    lines.append(f"      duration: const Duration(milliseconds: 300),")
    lines.append(f"      vsync: this,")
    lines.append(f"    );")
    lines.append(f"    _fadeAnimation = CurvedAnimation(")
    lines.append(f"      parent: _controller,")
    lines.append(f"      curve: Curves.easeInOut,")
    lines.append(f"    );")
    lines.append(f"    _loadData();")
    lines.append(f"  }}")
    lines.append(f"")
    lines.append(f"  Future<void> _loadData() async {{")
    lines.append(f"    try {{")
    lines.append(f"      await Future.delayed(const Duration(milliseconds: 500));")
    lines.append(f"      setState(() {{")
    lines.append(f"        _data = {{'value': 42, 'label': '{class_name}'}};")
    lines.append(f"        _isLoading = false;")
    lines.append(f"      }});")
    lines.append(f"      _controller.forward();")
    lines.append(f"    }} catch (e) {{")
    lines.append(f"      setState(() {{")
    lines.append(f"        _error = e.toString();")
    lines.append(f"        _isLoading = false;")
    lines.append(f"      }});")
    lines.append(f"    }}")
    lines.append(f"  }}")
    lines.append(f"")
    lines.append(f"  @override")
    lines.append(f"  void dispose() {{")
    lines.append(f"    _controller.dispose();")
    lines.append(f"    super.dispose();")
    lines.append(f"  }}")
    lines.append(f"")
    lines.append(f"  @override")
    lines.append(f"  Widget build(BuildContext context) {{")
    lines.append(f"    if (_isLoading) {{")
    lines.append(f"      return const Center(child: CircularProgressIndicator());")
    lines.append(f"    }}")
    lines.append(f"    if (_error != null) {{")
    lines.append(f"      return Center(child: Text('Error: $_error'));")
    lines.append(f"    }}")
    lines.append(f"    return FadeTransition(")
    lines.append(f"      opacity: _fadeAnimation,")
    lines.append(f"      child: GestureDetector(")
    lines.append(f"        onTap: widget.onTap,")
    lines.append(f"        child: Container(")
    lines.append(f"          padding: const EdgeInsets.all(16),")
    lines.append(f"          decoration: BoxDecoration(")
    lines.append(f"            borderRadius: BorderRadius.circular(12),")
    lines.append(f"            color: Theme.of(context).cardColor,")
    lines.append(f"            boxShadow: [")
    lines.append(f"              BoxShadow(")
    lines.append(f"                color: Colors.black.withOpacity(0.1),")
    lines.append(f"                blurRadius: 8,")
    lines.append(f"                offset: const Offset(0, 2),")
    lines.append(f"              ),")
    lines.append(f"            ],")
    lines.append(f"          ),")
    lines.append(f"          child: Column(")
    lines.append(f"            crossAxisAlignment: CrossAxisAlignment.start,")
    lines.append(f"            children: [")
    lines.append(f"              Text(")
    lines.append(f"                '{class_name}',")
    lines.append(f"                style: Theme.of(context).textTheme.titleMedium,")
    lines.append(f"              ),")
    lines.append(f"              const SizedBox(height: 8),")
    lines.append(f"              Text(")
    lines.append(f"                '${{_data?['value'] ?? 0}}',")
    lines.append(f"                style: Theme.of(context).textTheme.headlineLarge,")
    lines.append(f"              ),")
    lines.append(f"              if (widget.showDetails) ...[")
    lines.append(f"                const SizedBox(height: 12),")
    lines.append(f"                Text(")
    lines.append(f"                  'Player: ${{widget.playerId}}',")
    lines.append(f"                  style: Theme.of(context).textTheme.bodySmall,")
    lines.append(f"                ),")
    lines.append(f"              ],")
    lines.append(f"            ],")
    lines.append(f"          ),")
    lines.append(f"        ),")
    lines.append(f"      ),")
    lines.append(f"    );")
    lines.append(f"  }}")
    lines.append(f"}}")
    lines.append(f"")

with open("volt-rush/lib/widgets/analytics_dashboard.dart", "w") as f:
    f.write("\n".join(lines))

print(f"Generated {len(lines)} lines")
