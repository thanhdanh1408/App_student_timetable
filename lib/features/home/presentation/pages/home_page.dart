// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/providers/auth_provider.dart';
import '/core/widgets/app_drawer.dart';
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
        final email = auth.userEmail ?? "bạn";
        final String fullname = email.isNotEmpty ? email[0].toUpperCase() + email.substring(1).split('@')[0] : "Bạn";

        return Scaffold(
          appBar: AppBar(
            title: const Text("Trang chủ", style: TextStyle(color: Colors.white)),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chào mừng – ĐÃ FIX FULLNAME
                        Text(
                          "Chào mừng, $fullname!",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Hôm nay là ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 24),

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
                              title: "Môn học",
                              value: "${home.summary.subjectCount}",
                              icon: Icons.book,
                              color: Colors.blue,
                            ),
                            _SummaryCard(
                              title: "Lịch học hôm nay",
                              value: "${home.summary.scheduleTodayCount}",
                              icon: Icons.today,
                              color: Colors.green,
                            ),
                            _SummaryCard(
                              title: "Lịch thi",
                              value: "${home.summary.upcomingExamCount}",
                              icon: Icons.assignment,
                              color: Colors.orange,
                            ),
                            _SummaryCard(
                              title: "Thông báo",
                              value: "${home.summary.notificationCount}",
                              icon: Icons.notifications,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Lịch học hôm nay
                        const Text("Lịch học hôm nay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (home.summary.todaySchedules.isEmpty)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.event_busy, color: Colors.grey),
                              title: const Text("Không có lịch học hôm nay"),
                              subtitle: const Text("Hãy nghỉ ngơi hoặc ôn tập nhé!"),
                            ),
                          )
                        else
                          ...home.summary.todaySchedules.map((item) {
                            final parts = item.split('|');
                            final subjectName = parts[0];
                            final teacherName = parts.length > 1 ? parts[1] : 'N/A';
                            final time = parts.length > 2 ? parts[2] : 'N/A';
                            final location = parts.length > 3 ? parts[3] : 'N/A';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.access_time, color: Colors.indigo),
                                title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('GV: $teacherName'),
                                    Text('Thời gian: $time'),
                                    Text('Địa điểm: $location'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          }),

                        const SizedBox(height: 24),

                        // Lịch thi sắp tới
                        const Text("Lịch thi sắp tới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (home.summary.upcomingExams.isEmpty)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: const Text("Không có lịch thi sắp tới"),
                              subtitle: const Text("Trong 3 ngày tới"),
                            ),
                          )
                        else
                          ...home.summary.upcomingExams.map((exam) {
                            final parts = exam.split('|');
                            final subjectName = parts[0];
                            final examType = parts.length > 1 ? parts[1] : 'N/A';
                            final examDate = parts.length > 2 ? parts[2] : 'N/A';
                            final examTime = parts.length > 3 ? parts[3] : 'N/A';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.warning, color: Colors.red),
                                title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kỳ thi: $examType'),
                                    Text('Ngày: $examDate'),
                                    Text('Giờ: $examTime'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
        );
      },
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
