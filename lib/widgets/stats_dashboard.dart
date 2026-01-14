import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';
import '../utils/theme_provider.dart';

class StatsDashboard extends StatelessWidget {
  final TaskStats stats;

  const StatsDashboard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final data = stats.categoryDistribution.where((d) => d.value > 0).toList();
    
    final colors = [
      themeProvider.accentColorLight,
      Colors.purple,
      Colors.red,
      Colors.green,
      Colors.grey,
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(context, themeProvider),
          const SizedBox(height: 24),
          _buildChartsSection(context, data, colors, themeProvider),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, ThemeProvider themeProvider) {
    final statCards = [
      {
        'label': 'Total Tasks',
        'value': stats.total,
        'icon': Icons.task_alt,
        'color': themeProvider.accentColorLight,
        'bgColor': themeProvider.accentColorLight.withOpacity(0.1),
      },
      {
        'label': 'Completed',
        'value': stats.completed,
        'icon': Icons.check_circle,
        'color': Colors.green,
        'bgColor': Colors.green.withOpacity(0.1),
      },
      {
        'label': 'Pending',
        'value': stats.pending,
        'icon': Icons.schedule,
        'color': Colors.amber,
        'bgColor': Colors.amber.withOpacity(0.1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: statCards.length,
      itemBuilder: (context, index) {
        final card = statCards[index];
        return Card(
          color: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${card['value']}',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    card['icon'] as IconData,
                    size: 28,
                    color: card['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: index * 100))
          .scale(delay: Duration(milliseconds: index * 100));
      },
    );
  }

  Widget _buildChartsSection(
    BuildContext context,
    List<CategoryDistribution> data,
    List<Color> colors,
    ThemeProvider themeProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Distribution',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: data.isNotEmpty
                        ? PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              sections: data.asMap().entries.map((entry) {
                                final index = entry.key;
                                final category = entry.value;
                                final color = colors[index % colors.length];
                                
                                return PieChartSectionData(
                                  color: color,
                                  value: category.value.toDouble(),
                                  title: '${category.value}',
                                  radius: 80,
                                  titleStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  badgeWidget: _Badge(
                                    category.name,
                                    color,
                                  ),
                                  badgePositionPercentageOffset: .98,
                                );
                              }).toList(),
                            ),
                          )
                        : Center(
                            child: Text(
                              'No active tasks to analyze',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                  ),
                  if (data.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildLegend(data, colors, context),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: themeProvider.accentColorLight,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.accentColorLight.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ).animate()
                  .scale(duration: 700.ms, delay: 500.ms),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Boost your productivity!',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "You've completed "),
                              TextSpan(
                                text: '${stats.completed}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                  decorationThickness: 2,
                                ),
                              ),
                              const TextSpan(text: ' tasks recently.\nKeep up the momentum to hit your weekly targets!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to reports or show analytics
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: themeProvider.accentColorLight,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Reports',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate()
            .fadeIn(delay: 300.ms)
            .slideX(begin: 0.2, end: 0, duration: 500.ms),
        ),
      ],
    );
  }

  Widget _buildLegend(List<CategoryDistribution> data, List<Color> colors, BuildContext context) {
    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final color = colors[index % colors.length];
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${category.value}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
