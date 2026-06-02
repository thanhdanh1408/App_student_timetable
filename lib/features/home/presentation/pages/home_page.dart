// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/core/providers/auth_provider.dart';
import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/l10n/app_localizations.dart';
import '/core/services/widget_service.dart';
import '../../../subjects/presentation/viewmodels/subjects_viewmodel.dart';
import '../../../schedule/presentation/viewmodels/schedule_viewmodel.dart';
import '../../../exam/presentation/viewmodels/exam_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load summary data after widget is built - không chờ để tránh stuck
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final subjectsViewModel = context.read<SubjectsViewModel>();
        final scheduleViewModel = context.read<ScheduleViewModel>();
        final examViewModel = context.read<ExamViewModel>();
        final homeViewModel = context.read<HomeViewModel>();

        subjectsViewModel.load();
        scheduleViewModel.load();
        examViewModel.load();
        // Load summary nhưng không chờ
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          homeViewModel.loadSummary();
          // Update Android widget
          WidgetService().updateWidget();
        });
      } catch (e) {
        debugPrint("Error loading home data: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final home = context.watch<HomeViewModel>();
        final l = AppLocalizations.of(context);
        final email = auth.userEmail ?? "bạn";
        final String fullname = email.isNotEmpty ? email[0].toUpperCase() + email.substring(1).split('@')[0] : "Bạn";

        return Scaffold(
          appBar: AppBar(
            title: Text(l.home, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => context.read<HomeViewModel>().loadSummary(),
              ),
            ],
          ),
          drawer: const AppDrawer(currentRoute: '/home'),
          body: RefreshIndicator(
                  onRefresh: () async {
                    final subjectsViewModel = context.read<SubjectsViewModel>();
                    final scheduleViewModel = context.read<ScheduleViewModel>();
                    final examViewModel = context.read<ExamViewModel>();
                    final homeViewModel = context.read<HomeViewModel>();

                    await subjectsViewModel.load();
                    await scheduleViewModel.load();
                    await examViewModel.load();
                    await homeViewModel.loadSummary();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).viewPadding.bottom,
                    ),
                    child: home.isLoading
                        ? _buildShimmerLoading()
                        : _buildContent(home, fullname),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerHeroHeader(),
        const SizedBox(height: 16),
        const ShimmerGridLoading(itemCount: 4),
        const SizedBox(height: 16),
        const ShimmerGridLoading(itemCount: 4),
        const SizedBox(height: 16),
        ShimmerListLoading(itemCount: 3, itemHeight: 80),
      ],
    );
  }

  Widget _buildContent(HomeViewModel home, String fullname) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroHeader(
          greeting: l.welcome(fullname),
          detail: l.isVietnamese
              ? 'Hôm nay có ${home.summary.scheduleTodayCount} buổi học, tổng ${home.summary.subjectCount} môn đang theo dõi'
              : 'You have ${home.summary.scheduleTodayCount} class sessions today, tracking ${home.summary.subjectCount} subjects',
        ),
        const SizedBox(height: 16),

        // Quick actions
        Text(
          l.quickAccess,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: [
            _QuickAction(icon: Icons.book, label: l.subjects, route: '/subjects'),
            _QuickAction(icon: Icons.calendar_month, label: l.schedule, route: '/schedule'),
            _QuickAction(icon: Icons.assignment, label: l.exam, route: '/exam'),
            _QuickAction(icon: Icons.task_alt, label: l.tasks, route: '/tasks'),
          ],
        ),
        const SizedBox(height: 20),

        // 4 ô vuông tóm tắt
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.25,
          children: [
            _SummaryCard(
              title: l.subjects,
              value: "${home.summary.subjectCount}",
              icon: Icons.book,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: l.todaySchedule,
              value: "${home.summary.scheduleTodayCount}",
              icon: Icons.today,
              color: Colors.green,
            ),
            _SummaryCard(
              title: l.exam,
              value: "${home.summary.upcomingExamCount}",
              icon: Icons.assignment,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: l.notifications,
              value: "${home.summary.notificationCount}",
              icon: Icons.notifications,
              color: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Lịch học hôm nay
        Text(l.todaySchedule, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (home.summary.todaySchedules.isEmpty)
          _buildEmptySection(
            icon: Icons.event_available,
            title: l.noScheduleToday,
            subtitle: l.restOrStudy,
          )
        else
          ...home.summary.todaySchedules.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final parts = item.split('|');
            final subjectName = parts[0];
            final teacherName = parts.length > 1 ? parts[1] : 'N/A';
            final time = parts.length > 2 ? parts[2] : 'N/A';
            final location = parts.length > 3 ? parts[3] : 'N/A';
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + index * 60),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    child: const Icon(Icons.access_time, color: Colors.indigo),
                  ),
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.isVietnamese ? 'GV: $teacherName' : 'Teacher: $teacherName'),
                      Text(l.isVietnamese ? 'Thời gian: $time' : 'Time: $time'),
                      Text(l.isVietnamese ? 'Địa điểm: $location' : 'Location: $location'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            );
          }),

        const SizedBox(height: 24),

        // Lịch thi sắp tới
        Text(l.upcomingExams, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (home.summary.upcomingExams.isEmpty)
          _buildEmptySection(
            icon: Icons.check_circle_outline,
            title: l.noUpcomingExam,
            subtitle: l.inNext3Days,
          )
        else
          ...home.summary.upcomingExams.asMap().entries.map((entry) {
            final index = entry.key;
            final exam = entry.value;
            final parts = exam.split('|');
            final subjectName = parts[0];
            final examType = parts.length > 1 ? parts[1] : 'N/A';
            final examDate = parts.length > 2 ? parts[2] : 'N/A';
            final examTime = parts.length > 3 ? parts[3] : 'N/A';
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + index * 60),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  ),
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.isVietnamese ? 'Kỳ thi: $examType' : 'Exam: $examType'),
                      Text(l.isVietnamese ? 'Ngày: $examDate' : 'Date: $examDate'),
                      Text(l.isVietnamese ? 'Giờ: $examTime' : 'Time: $examTime'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(icon, color: Colors.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String greeting;
  final String detail;

  const _HeroHeader({
    required this.greeting,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.go(route),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
