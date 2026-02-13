import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../widgets/chart_widget.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientStart,
              AppColors.bgGradientEnd,
            ],
          ),
        ),
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.panelBorder),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Text(
                    'Liquidity Print',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.neonBlue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  // User Info
                  Row(
                    children: [
                      Icon(
                        widget.user.isActive ? Icons.verified : Icons.lock,
                        color: widget.user.isActive ? AppColors.neonGreen : AppColors.neonYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'User: ${widget.user.email.split('@')[0]}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPlanColor(widget.user.plan).withOpacity(0.2),
                          border: Border.all(color: _getPlanColor(widget.user.plan)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Plan: ${widget.user.planDisplayName}',
                          style: TextStyle(
                            color: _getPlanColor(widget.user.plan),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            // Main Content - Chart
            const Expanded(
              child: ChartWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'free':
        return AppColors.textSecondary;
      case 'basic':
        return AppColors.neonYellow;
      case 'pro':
        return AppColors.neonPurple;
      case 'premium':
        return AppColors.neonGreen;
      default:
        return AppColors.neonBlue;
    }
  }
}
