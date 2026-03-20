# KẾ HOẠCH PHÁT TRIỂN - ĐỒ ÁN CNPM 2
## Student Timetable App - Phase 2

**Thời gian thực hiện**: 15 tuần (Tháng 3 - Tháng 6, 2026)
**Loại hình**: Dự án cá nhân (1 người)

---

## 📋 TỔNG QUAN DỰ ÁN

### Tính năng đã có (CNPM 1):
- ✅ Xác thực người dùng (Firebase Authentication)
- ✅ Quản lý môn học (CRUD)
- ✅ Quản lý lịch học (CRUD)
- ✅ Quản lý lịch thi (CRUD)
- ✅ Thông báo nội bộ (Local Notifications)
- ✅ Cài đặt ứng dụng cơ bản
- ✅ Trang chủ tổng quan

### Mục tiêu phát triển CNPM 2:
- 🎯 Test và fix bugs từ CNPM 1
- 🎯 Nâng cao trải nghiệm người dùng (UX/UI)
- 🎯 Thêm tính năng học tập và quản lý
- 🎯 Tối ưu hiệu suất và bảo mật
- 🎯 Tích hợp tính năng thông minh (tùy chọn)

---

## 📅 TIMELINE CHI TIẾT

### **TUẦN 1-2: KHỞI ĐỘNG VÀ LẬP KẾ HOẠCH (3/3/2026 - 16/3/2026)**

| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Phân tích yêu cầu CNPM 2 | Not Started | 0% | Bạn | 3/3/2026 | 5/3/2026 | Xác định scope dự án cá nhân |
| Review toàn bộ code CNPM 1 | Not Started | 0% | Bạn | 3/3/2026 | 7/3/2026 | Code review, liệt kê bugs |
| Lập danh sách bugs và issues | Not Started | 0% | Bạn | 6/3/2026 | 8/3/2026 | Priority: Critical → Low |
| Thiết kế kiến trúc cho features mới | Not Started | 0% | Bạn | 9/3/2026 | 14/3/2026 | Database schema, wireframes |
| Lập kế hoạch chi tiết các Sprint | Not Started | 0% | Bạn | 13/3/2026 | 16/3/2026 | Realistic timeline cho 1 người |

---

### **TUẦN 3: TESTING & BUG FIXING CNPM 1 (17/3/2026 - 23/3/2026)**

#### **Theme: Stabilize Current App**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Test toàn bộ authentication flow | Not Started | 0% | Bạn | 17/3/2026 | 18/3/2026 | Login, register, forgot password |
| Test CRUD subjects | Not Started | 0% | Bạn | 17/3/2026 | 18/3/2026 | Add, edit, delete, view |
| Test CRUD schedules | Not Started | 0% | Bạn | 18/3/2026 | 19/3/2026 | Conflicts, notifications |
| Test CRUD exams | Not Started | 0% | Bạn | 19/3/2026 | 20/3/2026 | Date validation, reminders |
| Test notifications system | Not Started | 0% | Bạn | 20/3/2026 | 21/3/2026 | Local notifications, permissions |
| Fix critical bugs | Not Started | 0% | Bạn | 21/3/2026 | 22/3/2026 | Ưu tiên bugs HIGH priority |
| Test trên nhiều devices | Not Started | 0% | Bạn | 22/3/2026 | 23/3/2026 | Android/iOS, screen sizes |
| Document bugs đã fix | Not Started | 0% | Bạn | 23/3/2026 | 23/3/2026 | Changelog, notes |

---

### **TUẦN 4-5: SPRINT 1 - CẢI THIỆN UI/UX (24/3/2026 - 6/4/2026)**

#### **Theme 1.1: Redesign UI**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Research UI/UX best practices | Not Started | 0% | Bạn | 24/3/2026 | 25/3/2026 | Material Design 3, inspiration |
| Sketch wireframes cho UI mới | Not Started | 0% | Bạn | 25/3/2026 | 27/3/2026 | Paper/Figma sketches |
| Implement Dark Mode | Not Started | 0% | Bạn | 28/3/2026 | 1/4/2026 | ThemeProvider, save preference |
| Cải thiện Home Dashboard | Not Started | 0% | Bạn | 1/4/2026 | 3/4/2026 | Better layout, quick actions |
| Redesign Schedule Page (Calendar View) | Not Started | 0% | Bạn | 3/4/2026 | 5/4/2026 | Week/Month view với table_calendar |
| Thêm animations | Not Started | 0% | Bạn | 5/4/2026 | 6/4/2026 | Smooth transitions |

---

### **TUẦN 6-7: SPRINT 2 - QUẢN LÝ HỌC TẬP NÂNG CAO (7/4/2026 - 20/4/2026)**

#### **Theme 2.1: Quản lý điểm số**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Thiết kế Grades module | Not Started | 0% | Bạn | 7/4/2026 | 8/4/2026 | Database schema, entities |
| Implement Firestore grades collection | Not Started | 0% | Bạn | 8/4/2026 | 10/4/2026 | CRUD operations |
| UI nhập và xem điểm | Not Started | 0% | Bạn | 10/4/2026 | 12/4/2026 | Forms, lists |
| Tính GPA tự động | Not Started | 0% | Bạn | 12/4/2026 | 13/4/2026 | Logic + display |

#### **Theme 2.2: To-Do List & Assignments**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Thiết kế Tasks module | Not Started | 0% | Bạn | 14/4/2026 | 15/4/2026 | Database schema |
| Implement Firestore tasks collection | Not Started | 0% | Bạn | 15/4/2026 | 17/4/2026 | CRUD với priority, status |
| UI To-Do List Page | Not Started | 0% | Bạn | 17/4/2026 | 19/4/2026 | Checkbox, filter, sort |
| Tích hợp reminder | Not Started | 0% | Bạn | 19/4/2026 | 20/4/2026 | Notifications |

---

### **TUẦN 8-9: SPRINT 3 - TÍNH NĂNG BỔ SUNG (21/4/2026 - 4/5/2026)**

#### **Theme 3.1: Notes & Study Materials**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Thiết kế Notes module | Not Started | 0% | Bạn | 21/4/2026 | 22/4/2026 | Rich text notes |
| Implement CRUD Notes | Not Started | 0% | Bạn | 22/4/2026 | 24/4/2026 | Link to subjects |
| UI Notes Editor | Not Started | 0% | Bạn | 24/4/2026 | 27/4/2026 | Text formatting, attachments |
| Search và filter notes | Not Started | 0% | Bạn | 27/4/2026 | 28/4/2026 | Full-text search |

#### **Theme 3.2: Export & Sharing**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Export schedule to PDF | Not Started | 0% | Bạn | 29/4/2026 | 1/5/2026 | pdf package |
| Export to iCal format | Not Started | 0% | Bạn | 1/5/2026 | 2/5/2026 | Import vào calendar khác |
| Share schedule via link | Not Started | 0% | Bạn | 2/5/2026 | 4/5/2026 | Share_plus package |

---

### **TUẦN 10-11: SPRINT 4 - BẢO MẬT & HIỆU NĂNG (5/5/2026 - 18/5/2026)**

#### **Theme 4.1: Bảo mật**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Implement Firebase Security Rules | Not Started | 0% | Bạn | 5/5/2026 | 7/5/2026 | User-specific data access |
| Validate input data | Not Started | 0% | Bạn | 7/5/2026 | 9/5/2026 | Prevent injection |
| Secure local storage | Not Started | 0% | Bạn | 9/5/2026 | 11/5/2026 | Encrypt sensitive data |
| Security audit | Not Started | 0% | Bạn | 11/5/2026 | 12/5/2026 | Check vulnerabilities |

#### **Theme 4.2: Tối ưu hiệu năng**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Optimize Firestore queries | Not Started | 0% | Bạn | 12/5/2026 | 14/5/2026 | Pagination, indexing |
| Implement caching | Not Started | 0% | Bạn | 14/5/2026 | 16/5/2026 | Reduce API calls |
| Optimize images và assets | Not Started | 0% | Bạn | 16/5/2026 | 17/5/2026 | Compress, lazy load |
| Performance profiling | Not Started | 0% | Bạn | 17/5/2026 | 18/5/2026 | Fix bottlenecks |

---

### **TUẦN 12-13: SPRINT 5 - POLISH & UX (19/5/2026 - 1/6/2026)**

#### **Theme 5.1: UI Polish**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Polish UI cho tất cả pages | Not Started | 0% | Bạn | 19/5/2026 | 22/5/2026 | Consistency, spacing, colors |
| Improve error handling UI | Not Started | 0% | Bạn | 22/5/2026 | 24/5/2026 | User-friendly messages |
| Add loading states | Not Started | 0% | Bạn | 24/5/2026 | 25/5/2026 | Shimmer, spinners |
| Improve empty states | Not Started | 0% | Bạn | 25/5/2026 | 26/5/2026 | Helpful placeholders |

#### **Theme 5.2: Advanced Features (Optional)**
| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Widget Android (optional) | Not Started | 0% | Bạn | 27/5/2026 | 29/5/2026 | Today's schedule |
| Backup & Restore | Not Started | 0% | Bạn | 29/5/2026 | 31/5/2026 | Export/import all data |
| Thêm đa ngôn ngữ (optional) | Not Started | 0% | Bạn | 31/5/2026 | 1/6/2026 | Tiếng Việt + English |

---

### **TUẦN 14: TESTING TỔNG THỂ (2/6/2026 - 8/6/2026)**

| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Test tất cả features mới | Not Started | 0% | Bạn | 2/6/2026 | 4/6/2026 | End-to-end testing |
| Test trên nhiều devices | Not Started | 0% | Bạn | 4/6/2026 | 5/6/2026 | Different screen sizes |
| Performance testing | Not Started | 0% | Bạn | 5/6/2026 | 6/6/2026 | Check app speed, memory |
| Fix bugs tìm được | Not Started | 0% | Bạn | 6/6/2026 | 8/6/2026 | Priority: Critical first |

---



---

### **TUẦN 15: DEPLOYMENT & TÀI LIỆU (9/6/2026 - 15/6/2026)**

| TaskDetail | Status | Process | Who | DateBegin | Deadline | Note |
|------------|--------|---------|-----|-----------|----------|------|
| Viết tài liệu kỹ thuật | Not Started | 0% | Bạn | 9/6/2026 | 11/6/2026 | Architecture, features |
| Viết User Manual | Not Started | 0% | Bạn | 9/6/2026 | 11/6/2026 | Hướng dẫn sử dụng |
| Chuẩn bị báo cáo đồ án | Not Started | 0% | Bạn | 10/6/2026 | 13/6/2026 | Report CNPM 2 |
| Build production APK | Not Started | 0% | Bạn | 12/6/2026 | 13/6/2026 | Release build |
| Test production build | Not Started | 0% | Bạn | 13/6/2026 | 14/6/2026 | Final check |
| Presentation slides & Demo video | Not Started | 0% | Bạn | 11/6/2026 | 14/6/2026 | Final presentation |
| Final Review & Submission | Not Started | 0% | Bạn | 15/6/2026 | 15/6/2026 | Nộp đồ án |

---

## 🎯 PHÂN CÔNG VAI TRÒ

### Dự án cá nhân:
**Bạn** sẽ đảm nhận TẤT CẢ các vai trò:
- 📋 **Project Manager**: Lập kế hoạch, tracking tiến độ
- 💻 **Full Stack Developer**: Backend + Frontend
- 🎨 **UI/UX Designer**: Thiết kế giao diện
- 🧪 **QA Tester**: Testing và quality assurance
- 📚 **Technical Writer**: Viết tài liệu
- 🚀 **DevOps**: Build và deployment

### Tips cho làm việc cá nhân:
- ✅ Chia nhỏ tasks, làm từng bước
- ✅ Tập trung 1 feature mỗi lần
- ✅ Test ngay sau khi code
- ✅ Document trong lúc code
- ✅ Commit thường xuyên
- ✅ Nghỉ ngơi hợp lý để tránh burnout

---

## 📊 DEPENDENCIES & PACKAGES MỚI

### Packages cần thêm (priority-based):

#### High Priority (Must Have)
```yaml
# Calendar & Date
- table_calendar: ^3.0.9  # Calendar view

# UI Enhancement
- shimmer: ^3.0.0  # Loading states
- lottie: ^3.0.0  # Animations (optional)

# Export & Share
- pdf: ^3.10.7  # Export PDF
- share_plus: ^7.2.1  # Share functionality
```

#### Medium Priority (Nice to Have)
```yaml
# Charts (nếu làm grades module)
- fl_chart: ^0.66.0

# Rich text notes
- flutter_quill: ^9.0.0

# Image handling
- image_picker: ^1.0.7
- image_cropper: ^5.0.1
```

#### Low Priority (Optional)
```yaml
# Internationalization
- flutter_localizations: (SDK)

# Widget
- home_widget: ^0.4.1  # Android widget

# ML/AI (nếu có thời gian)
- google_ml_kit: ^0.16.3
```

---

## ⚠️ RISKS & MITIGATION

| Risk | Impact | Mitigation Strategy |
|------|--------|---------------------|
| Scope quá lớn cho 1 người | High | Ưu tiên Must-Have features, các features khác là optional |
| Thiếu kiến thức về 1 số technology | Medium | Học từng bước, tận dụng tutorials, documentation |
| Burnout - làm quá nhiều | High | Nghỉ ngơi hợp lý, không overwork, 8h/ngày max |
| Bug phức tạp khó fix | Medium | Debug từng bước, hỏi trên Stack Overflow, ChatGPT |
| Thiếu thời gian testing | Medium | Test ngay khi code, không để tới cuối |
| Deploy issues | Low | Follow official Flutter deployment guides |
| Firebase cost | Low | Dùng free tier, monitor usage |

---

## 📈 SUCCESS METRICS

### KPIs cho CNPM 2 (Cá nhân):
- ✅ 80%+ tính năng high priority được hoàn thành
- ✅ App chạy ổn định, không crash
- ✅ App launch time < 3 seconds
- ✅ Tất cả features chính đều work
- ✅ Documentation đầy đủ (README, code comments)
- ✅ Báo cáo đồ án hoàn chỉnh
- ✅ Demo video và presentation ready

---

## 📝 NOTES

### Lưu ý cho development (Cá nhân):
1. **Daily progress**: Track tiến độ hàng ngày trong CSV file
2. **Commit thường xuyên**: Mỗi ngày ít nhất 1 commit
3. **Git workflow**: Feature branch → Test → Merge to main
4. **Documentation**: Comment code, update README
5. **Testing**: Test ngay sau khi code feature mới
6. **Time management**: Làm 6-8 tiếng/ngày, tránh overwork
7. **Version control**: v2.0.0 cho CNPM 2
8. **Backup**: Push code lên GitHub thường xuyên

### Khuyến nghị:
- Bắt đầu với features quan trọng nhất (MVP)
- Hoàn thành testing CNPM 1 trước khi làm features mới
- Làm từng Sprint, review sau mỗi Sprint
- Có thể điều chỉnh timeline nếu cần
- Priority: Quality > Quantity
- Nghỉ ngơi đầy đủ, giữ sức khỏe
- Hỏi giúp khi gặp khó khăn (Stack Overflow, ChatGPT, forums)

---

## 📚 TÀI LIỆU THAM KHẢO
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Best Practices: https://flutter.dev/docs/testing
- Material Design 3: https://m3.material.io
- Clean Architecture: https://blog.cleancoder.com

---

**Tài liệu này được tạo**: 3/3/2026  
**Phiên bản**: 1.0  
**Người tạo**: GitHub Copilot  
**Trạng thái**: Draft - Cần review và điều chỉnh theo team size và resources thực tế
