import 'package:flutter/material.dart';

/// Simple localization system for Vietnamese and English.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  bool get isVietnamese => locale.languageCode == 'vi';

  // ─── Common ─────────────────────────────────────────────────────────
  String get appTitle => isVietnamese ? 'Thời khóa biểu Sinh viên' : 'Student Timetable';
  String get home => isVietnamese ? 'Trang chủ' : 'Home';
  String get subjects => isVietnamese ? 'Môn học' : 'Subjects';
  String get schedule => isVietnamese ? 'Lịch học' : 'Schedule';
  String get exam => isVietnamese ? 'Lịch thi' : 'Exams';
  String get tasks => isVietnamese ? 'Công việc' : 'Tasks';
  String get grades => isVietnamese ? 'Quản lý điểm' : 'Grades';
  String get notes => isVietnamese ? 'Ghi chú' : 'Notes';
  String get notifications => isVietnamese ? 'Thông báo' : 'Notifications';
  String get settings => isVietnamese ? 'Cài đặt' : 'Settings';

  // ─── Actions ────────────────────────────────────────────────────────
  String get add => isVietnamese ? 'Thêm' : 'Add';
  String get edit => isVietnamese ? 'Sửa' : 'Edit';
  String get delete => isVietnamese ? 'Xóa' : 'Delete';
  String get cancel => isVietnamese ? 'Hủy' : 'Cancel';
  String get save => isVietnamese ? 'Lưu' : 'Save';
  String get retry => isVietnamese ? 'Thử lại' : 'Retry';
  String get search => isVietnamese ? 'Tìm kiếm' : 'Search';
  String get filter => isVietnamese ? 'Lọc' : 'Filter';
  String get all => isVietnamese ? 'Tất cả' : 'All';
  String get close => isVietnamese ? 'Đóng' : 'Close';
  String get confirm => isVietnamese ? 'Xác nhận' : 'Confirm';
  String get loading => isVietnamese ? 'Đang tải...' : 'Loading...';

  // ─── Home Page ──────────────────────────────────────────────────────
  String welcome(String name) =>
      isVietnamese ? 'Chào mừng, $name!' : 'Welcome, $name!';
  String get quickAccess => isVietnamese ? 'Truy cập nhanh' : 'Quick Access';
  String get todaySchedule =>
      isVietnamese ? 'Lịch học hôm nay' : "Today's Schedule";
  String get upcomingExams =>
      isVietnamese ? 'Lịch thi sắp tới' : 'Upcoming Exams';
  String get noScheduleToday =>
      isVietnamese ? 'Không có lịch học hôm nay' : 'No classes today';
  String get noUpcomingExam =>
      isVietnamese ? 'Không có lịch thi sắp tới' : 'No upcoming exams';
  String get restOrStudy =>
      isVietnamese ? 'Hãy nghỉ ngơi hoặc ôn tập nhé!' : 'Rest or review!';
  String get inNext3Days =>
      isVietnamese ? 'Trong 3 ngày tới' : 'In the next 3 days';

  // ─── Subjects ───────────────────────────────────────────────────────
  String get searchSubjectOrTeacher =>
      isVietnamese ? 'Tìm môn học hoặc giảng viên...' : 'Search subject or teacher...';
  String get noSubjects =>
      isVietnamese ? 'Chưa có môn học nào' : 'No subjects yet';
  String get addSubject =>
      isVietnamese ? 'Thêm môn học' : 'Add Subject';
  String get noResults =>
      isVietnamese ? 'Không tìm thấy kết quả' : 'No results found';
  String get tryOtherKeyword =>
      isVietnamese ? 'Thử tìm kiếm với từ khóa khác' : 'Try a different keyword';

  // ─── Schedule ───────────────────────────────────────────────────────
  String get noSchedule =>
      isVietnamese ? 'Chưa có lịch học' : 'No schedule yet';
  String get addSchedule =>
      isVietnamese ? 'Thêm lịch học' : 'Add Schedule';

  // ─── Exam ───────────────────────────────────────────────────────────
  String get noExams =>
      isVietnamese ? 'Chưa có lịch thi nào' : 'No exams yet';
  String get addExam =>
      isVietnamese ? 'Thêm lịch thi' : 'Add Exam';
  String get upcoming => isVietnamese ? 'Sắp tới' : 'Upcoming';
  String get past => isVietnamese ? 'Đã qua' : 'Past';

  // ─── Grades ─────────────────────────────────────────────────────────
  String get noGrades =>
      isVietnamese ? 'Chưa có dữ liệu điểm' : 'No grades yet';
  String get addGrade =>
      isVietnamese ? 'Thêm điểm' : 'Add Grade';
  String get gpaOverview =>
      isVietnamese ? 'Tổng quan GPA' : 'GPA Overview';
  String get gpa10 => isVietnamese ? 'GPA hệ 10' : 'GPA (10)';
  String get gpa4 => isVietnamese ? 'GPA hệ 4' : 'GPA (4)';
  String get subjectCount => isVietnamese ? 'Số môn' : 'Subjects';

  // ─── Tasks ──────────────────────────────────────────────────────────
  String get noTasks =>
      isVietnamese ? 'Chưa có công việc' : 'No tasks yet';
  String get addTask =>
      isVietnamese ? 'Thêm task' : 'Add Task';
  String get pending => isVietnamese ? 'Đang chờ' : 'Pending';
  String get completed => isVietnamese ? 'Hoàn thành' : 'Completed';
  String progress(int done, int total) =>
      isVietnamese ? 'Tiến độ: $done/$total' : 'Progress: $done/$total';
  String get noPendingTasks =>
      isVietnamese ? 'Không có task đang chờ' : 'No pending tasks';
  String get noCompletedTasks =>
      isVietnamese ? 'Chưa hoàn thành task nào' : 'No completed tasks';

  // ─── Notes ──────────────────────────────────────────────────────────
  String get noNotes =>
      isVietnamese ? 'Chưa có ghi chú' : 'No notes yet';
  String get addNote =>
      isVietnamese ? 'Tạo ghi chú' : 'Create Note';
  String get searchNotes =>
      isVietnamese ? 'Tìm theo tiêu đề, nội dung, tag...' : 'Search by title, content, tag...';
  String noteCount(int count) =>
      isVietnamese ? '$count ghi chú' : '$count notes';

  // ─── Settings ───────────────────────────────────────────────────────
  String get general => isVietnamese ? 'Chung' : 'General';
  String get language => isVietnamese ? 'Ngôn ngữ' : 'Language';
  String get darkMode => isVietnamese ? 'Chế độ tối' : 'Dark Mode';
  String get dataSection => isVietnamese ? 'Dữ liệu' : 'Data';
  String get backup => isVietnamese ? 'Sao lưu dữ liệu' : 'Backup Data';
  String get backupDesc =>
      isVietnamese ? 'Xuất toàn bộ dữ liệu ra file JSON' : 'Export all data to JSON file';
  String get shareBackup =>
      isVietnamese ? 'Chia sẻ sao lưu' : 'Share Backup';
  String get shareBackupDesc =>
      isVietnamese ? 'Gửi file backup qua email, tin nhắn...' : 'Send backup via email, message...';
  String get restore =>
      isVietnamese ? 'Khôi phục dữ liệu' : 'Restore Data';
  String get restoreDesc =>
      isVietnamese ? 'Nhập dữ liệu từ file backup JSON' : 'Import data from backup JSON file';
  String get restoreConfirm =>
      isVietnamese ? 'Khôi phục dữ liệu?' : 'Restore data?';
  String get restoreWarning =>
      isVietnamese
          ? 'Dữ liệu cũ sẽ được gộp với dữ liệu từ file backup. Bạn có muốn tiếp tục?'
          : 'Existing data will be merged with backup data. Continue?';
  String get about => isVietnamese ? 'Về ứng dụng' : 'About';
  String get logOut => isVietnamese ? 'Đăng xuất' : 'Log Out';
  String get logOutConfirm =>
      isVietnamese ? 'Bạn có chắc muốn đăng xuất?' : 'Are you sure you want to log out?';

  // ─── Errors ─────────────────────────────────────────────────────────
  String get errorLoadingData =>
      isVietnamese ? 'Lỗi tải dữ liệu' : 'Error loading data';
  String get errorOccurred =>
      isVietnamese ? 'Đã xảy ra lỗi' : 'An error occurred';

  // ─── Success ────────────────────────────────────────────────────────
  String get addSuccess => isVietnamese ? '✅ Thêm thành công' : '✅ Added successfully';
  String get updateSuccess => isVietnamese ? '✅ Cập nhật thành công' : '✅ Updated successfully';
  String get deleteSuccess => isVietnamese ? '✅ Xóa thành công' : '✅ Deleted successfully';
  String get deleteConfirm => isVietnamese ? 'Bạn có chắc muốn xóa?' : 'Are you sure you want to delete?';

  // ─── Widget ─────────────────────────────────────────────────────────
  String get noClassesToday => isVietnamese ? 'Không có lịch học hôm nay' : 'No classes today';
  String get tapToOpen => isVietnamese ? 'Nhấn để mở app' : 'Tap to open app';

  // ─── Schedule Form ──────────────────────────────────────────────────
  String get addScheduleTitle => isVietnamese ? 'Thêm buổi học' : 'Add Class';
  String get editScheduleTitle => isVietnamese ? 'Chỉnh sửa buổi học' : 'Edit Class';
  String get selectSubject => isVietnamese ? 'Chọn môn học*' : 'Select Subject*';
  String get selectSubjectError => isVietnamese ? 'Chọn môn học' : 'Select a subject';
  String get selectDay => isVietnamese ? 'Thứ*' : 'Day*';
  String get selectDayError => isVietnamese ? 'Chọn thứ' : 'Select a day';
  String get location => isVietnamese ? 'Địa điểm' : 'Location';
  String get notesHint => isVietnamese ? 'Nhập ghi chú (tùy chọn)' : 'Enter notes (optional)';
  String get startTime => isVietnamese ? 'Giờ bắt đầu*' : 'Start Time*';
  String get endTime => isVietnamese ? 'Giờ kết thúc*' : 'End Time*';
  String get monday => isVietnamese ? 'Thứ 2' : 'Monday';
  String get tuesday => isVietnamese ? 'Thứ 3' : 'Tuesday';
  String get wednesday => isVietnamese ? 'Thứ 4' : 'Wednesday';
  String get thursday => isVietnamese ? 'Thứ 5' : 'Thursday';
  String get friday => isVietnamese ? 'Thứ 6' : 'Friday';
  String get saturday => isVietnamese ? 'Thứ 7' : 'Saturday';
  String get sunday => isVietnamese ? 'Chủ nhật' : 'Sunday';
  String get notSelected => isVietnamese ? 'Chưa chọn' : 'Not selected';
  String get selectStartEndTime =>
      isVietnamese ? 'Vui lòng chọn giờ bắt đầu và kết thúc' : 'Please select start and end time';
  String get endTimeAfterStart =>
      isVietnamese ? 'Giờ kết thúc phải sau giờ bắt đầu' : 'End time must be after start time';
  String get maxClassDuration =>
      isVietnamese ? 'Thời lượng buổi học không được vượt quá 6 giờ' : 'Class duration cannot exceed 6 hours';
  String get loadSubjectsFailed =>
      isVietnamese ? 'Lỗi tải danh sách môn học' : 'Failed to load subjects';
  String get editSchedule => isVietnamese ? 'Sửa' : 'Edit';
  String get deleteSchedule => isVietnamese ? 'Xóa' : 'Delete';
  String get deleteScheduleTitle => isVietnamese ? 'Xóa lịch học?' : 'Delete class?';
  String deleteScheduleConfirm(String subjectName) =>
      isVietnamese ? 'Bạn có chắc chắn muốn xóa lịch học của "$subjectName"?' : 'Are you sure you want to delete the class "$subjectName"?';

  // ─── Exam Form ──────────────────────────────────────────────────────
  String get addExamTitle => isVietnamese ? 'Thêm lịch thi' : 'Add Exam';
  String get editExamTitle => isVietnamese ? 'Sửa lịch thi' : 'Edit Exam';
  String get examDate => isVietnamese ? 'Ngày thi' : 'Exam Date';
  String get examTime => isVietnamese ? 'Giờ thi' : 'Exam Time';
  String get examRoom => isVietnamese ? 'Phòng thi' : 'Exam Room';
  String get selectExamDate => isVietnamese ? 'Chọn ngày thi' : 'Select exam date';
  String get selectExamTime => isVietnamese ? 'Chọn giờ thi' : 'Select exam time';
  String get deleteExamTitle => isVietnamese ? 'Xóa lịch thi?' : 'Delete exam?';
  String deleteExamConfirm(String subjectName) =>
      isVietnamese ? 'Bạn có chắc chắn muốn xóa lịch thi của "$subjectName"?' : 'Are you sure you want to delete the exam "$subjectName"?';
  String get addExamSuccess => isVietnamese ? '✅ Thêm lịch thi thành công' : '✅ Exam added successfully';
  String get updateExamSuccess => isVietnamese ? '✅ Cập nhật lịch thi thành công' : '✅ Exam updated successfully';
  String get deleteExamSuccess => isVietnamese ? '✅ Xóa lịch thi thành công' : '✅ Exam deleted successfully';

  // ─── Exam Types ─────────────────────────────────────────────────────
  String get midtermExam => isVietnamese ? 'Giữa kỳ' : 'Midterm';
  String get finalExam => isVietnamese ? 'Cuối kỳ' : 'Final';
  String get regularExam => isVietnamese ? 'Thường xuyên' : 'Regular';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}
