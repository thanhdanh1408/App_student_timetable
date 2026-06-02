import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/widgets/empty_state_widget.dart';
import '/core/l10n/app_localizations.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../widgets/note_card.dart';
import '../widgets/note_form_dialog.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _subjectFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesViewModel>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showForm({note}) {
    showDialog(
      context: context,
      builder: (_) => NoteFormDialog(
        note: note,
        onSave: (value) async {
          final vm = context.read<NotesViewModel>();
          if (note == null) {
            await vm.add(value);
          } else {
            await vm.update(value);
          }
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    final pageContext = context;
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa ghi chú?'),
        content: const Text('Bạn có chắc muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await pageContext.read<NotesViewModel>().delete(id);
              } catch (e) {
                if (!pageContext.mounted) return;
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: Text('❌ Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotesViewModel>();
    final l = AppLocalizations.of(context);

    final subjects = vm.notes
        .map((e) => e.subjectName)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    var filtered = vm.notes;
    if (_subjectFilter != 'all') {
      filtered = filtered.where((n) => n.subjectName == _subjectFilter).toList();
    }

    if (_searchCtrl.text.isNotEmpty) {
      final query = _searchCtrl.text.toLowerCase();
      filtered = filtered.where((n) {
        final title = n.title.toLowerCase();
        final content = n.content.toLowerCase();
        final tags = n.tags.join(' ').toLowerCase();
        return title.contains(query) || content.contains(query) || tags.contains(query);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notes, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(currentRoute: '/notes'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Error banner
            if (vm.error != null)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.error!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: vm.clearError,
                      child: Text(l.close),
                    ),
                  ],
                ),
              ),
            // Notes count summary
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                children: [
                  Icon(Icons.notes_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l.noteCount(vm.notes.length),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l.searchNotes,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Subject filter
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l.all),
                    selected: _subjectFilter == 'all',
                    onSelected: (_) => setState(() => _subjectFilter = 'all'),
                  ),
                  ...subjects.map(
                    (subject) => ChoiceChip(
                      label: Text(subject),
                      selected: _subjectFilter == subject,
                      onSelected: (_) => setState(() => _subjectFilter = subject),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: vm.isLoading
                  ? const Padding(
                      key: ValueKey('notes-loading'),
                      padding: EdgeInsets.only(top: 16),
                      child: ShimmerListLoading(itemCount: 4, itemHeight: 100),
                    )
                  : filtered.isEmpty
                      ? Padding(
                          key: const ValueKey('notes-empty'),
                          padding: const EdgeInsets.only(top: 60),
                          child: EmptyStateWidget(
                            icon: Icons.note_alt_outlined,
                            title: l.noNotes,
                            subtitle: _searchCtrl.text.isNotEmpty
                              ? '${l.noResults} "${_searchCtrl.text}"'
                              : (l.isVietnamese ? 'Nhấn nút + để tạo ghi chú mới' : 'Tap + to create a note'),
                            actionLabel: _searchCtrl.text.isEmpty ? l.addNote : null,
                            onAction: _searchCtrl.text.isEmpty ? () => _showForm() : null,
                          ),
                        )
                      : Column(
                          key: const ValueKey('notes-list'),
                          children: filtered.asMap().entries.map((entry) {
                            final index = entry.key;
                            final note = entry.value;
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 250 + index * 40),
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
                              child: NoteCard(
                                note: note,
                                onEdit: () => _showForm(note: note),
                                onDelete: () => _confirmDelete(note.id!),
                              ),
                            );
                          }).toList(),
                        ),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 80),
          ],
        ),
      ),
    );
  }
}
