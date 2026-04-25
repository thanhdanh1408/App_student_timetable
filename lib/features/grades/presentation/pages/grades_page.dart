import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_drawer.dart';

import '../viewmodels/grades_viewmodel.dart';
import '../widgets/grade_card.dart';
import '../widgets/grade_form_dialog.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesViewModel>().load();
    });
  }

  void _showForm({grade}) {
    showDialog(
      context: context,
      builder: (_) => GradeFormDialog(
        grade: grade,
        onSave: (value) async {
          final vm = context.read<GradesViewModel>();
          if (grade == null) {
            await vm.add(value);
          } else {
            await vm.update(value);
          }
        },
      ),
    );
  }

  void _confirmDelete(String id, String subjectName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa điểm?'),
        content: Text('Bạn có chắc muốn xóa điểm của môn "$subjectName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<GradesViewModel>().delete(id);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GradesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý điểm', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(currentRoute: '/grades'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.indigo.withOpacity(0.08),
                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan GPA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('GPA hệ 10: ${vm.gpa10.toStringAsFixed(2)}'),
                  Text('GPA hệ 4: ${vm.gpa4.toStringAsFixed(2)}'),
                  Text('Số môn đã có điểm: ${vm.grades.length}'),
                ],
              ),
            ),
            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.grades.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: Text('Chưa có dữ liệu điểm. Nhấn + để thêm.')),
              )
            else
              ...vm.grades.map(
                (g) => GradeCard(
                  grade: g,
                  onEdit: () => _showForm(grade: g),
                  onDelete: () => _confirmDelete(g.id!, g.subjectName ?? 'N/A'),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
