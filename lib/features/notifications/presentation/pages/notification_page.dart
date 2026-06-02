import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_drawer.dart';
import '/core/l10n/app_localizations.dart';
import '/features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load data khi page khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationViewModel = context.watch<NotificationViewModel>();
    final l = AppLocalizations.of(context);
    final notifications = notificationViewModel.notifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final readCount = notifications.where((n) => n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: '${l.all} (${notifications.length})'),
            Tab(text: l.isVietnamese ? 'Chưa đọc ($unreadCount)' : 'Unread ($unreadCount)'),
            Tab(text: l.isVietnamese ? 'Đã đọc ($readCount)' : 'Read ($readCount)'),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/notification'),
      body: notifications.isEmpty
          ? _buildEmptyState(l)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(notifications, l),
                _buildNotificationList(notifications.where((n) => !n.isRead).toList(), l),
                _buildNotificationList(notifications.where((n) => n.isRead).toList(), l),
              ],
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l.isVietnamese ? 'Chưa có thông báo' : 'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.isVietnamese
                ? 'Hệ thống sẽ gửi thông báo nhắc nhở\nvề lịch học và lịch thi'
                : 'The system will send reminder\nnotifications about classes and exams',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationEntity> notifications, AppLocalizations l) {
    if (notifications.isEmpty) {
      return _buildEmptyState(l);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationViewModel>().load();
      },
      child: ListView.builder(
        itemCount: notifications.length,
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          MediaQuery.of(context).viewPadding.bottom + 8,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isRead = notification.isRead;
          final notificationId = notification.id;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: isRead ? Colors.grey[100] : Colors.white,
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type)
                      .withOpacity(isRead ? 0.5 : 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                  fontSize: 15,
                  color: isRead ? Colors.grey[600] : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.scheduledFor, l),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    PopupMenuItem(
                      child: Text(l.isVietnamese ? '✓ Đánh dấu đã đọc' : '✓ Mark as read'),
                      onTap: () {
                        if (notificationId != null) {
                          context.read<NotificationViewModel>().markAsRead(notificationId);
                        }
                      },
                    ),
                  PopupMenuItem(
                    child: Text(l.isVietnamese ? '🗑️ Xóa' : '🗑️ Delete'),
                    onTap: () {
                      final id = notification.id;
                      if (id != null) {
                        context.read<NotificationViewModel>().deleteNotification(id);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'exam':
        return Colors.red;
      case 'schedule':
        return Colors.blue;
      case 'approaching':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'exam':
        return Icons.assignment;
      case 'schedule':
        return Icons.schedule;
      case 'approaching':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime, AppLocalizations l) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l.isVietnamese ? 'Vừa xong' : 'Just now';
    } else if (difference.inMinutes < 60) {
      return l.isVietnamese
          ? '${difference.inMinutes} phút trước'
          : '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return l.isVietnamese
          ? '${difference.inHours} giờ trước'
          : '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return l.isVietnamese
          ? '${difference.inDays} ngày trước'
          : '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
