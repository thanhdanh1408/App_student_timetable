# CNPM 2 - QUICK REFERENCE GUIDE

## 📊 Project Overview
- **Duration**: 15 tuần (3/3/2026 - 15/6/2026)
- **Total Tasks**: 53 tasks
- **Team Size**: 1 người (Dự án cá nhân)
- **Version**: v2.0.0

---

## 🎯 PRIORITY SUMMARY

### Must Have (High Priority) - 30 tasks
- Testing CNPM 1 app
- UI/UX improvements
- Grades Management System
- Tasks/To-Do List
- Security & Performance
- Documentation & Deployment

### Should Have (Medium Priority) - 15 tasks
- Notes module
- Export features
- Caching & Optimization
- UI Polish

### Could Have (Low Priority) - 8 tasks
- Widget
- Multi-language
- Advanced search
- iCal export

---

## 📅 SPRINT OVERVIEW

### Phase 1: Foundation (Tuần 1-2) - Setup
**Goal**: Chuẩn bị môi trường và lập kế hoạch
**Deliverables**: 
- Requirements analysis
- Architecture design
- Sprint planning complete

### Phase 2: Testing CNPM 1 (Tuần 3)
**Goal**: Test và fix bugs app hiện tại
**Deliverables**:
- All features tested
- Critical bugs fixed
- Stable app ready for enhancement

**Major Actions**:
- 🧪 Test toàn bộ features
- 🐞 Fix bugs ưu tiên
- 📝 Document issues

### Phase 3: User Experience (Tuần 4-7) - Sprint 1 & 2  
**Goal**: Cải thiện UI/UX và thêm tính năng học tập
**Deliverables**:
- Dark mode implemented
- New dashboard design
- Calendar view for schedules
- Grades management module
- To-Do list & assignments

**Major Features**:
- ✨ Giao diện mới với Material Design 3
- 📊 Quản lý điểm số và tính GPA
- ✅ To-Do List với reminders

### Phase 4: Additional Features (Tuần 8-9) - Sprint 3
**Goal**: Thêm tính năng bổ sung
**Deliverables**:
- Notes module
- Export to PDF/iCal
- Share functionality

**Major Features**:
- 📝 Ghi chú cho môn học
- 📥 Export và chia sẻ

### Phase 5: Quality (Tuần 10-11) - Sprint 4
**Goal**: Bảo mật và tối ưu
**Deliverables**:
- Firebase security rules
- Optimized queries
- Caching implemented
- Performance improved

**Major Features**:
- 🔒 Enhanced security
- ⚡ Performance optimization

### Phase 6: Polish (Tuần 12-13) - Sprint 5
**Goal**: Hoàn thiện và polish
**Deliverables**:
- UI polished
- Error handling improved
- Optional features (widget, i18n)
- Backup system

### Phase 7: Release (Tuần 14-15) - Testing & Deployment
**Goal**: Testing, documentation, release
**Deliverables**:
- All features tested
- Technical documentation
- User manual
- Production build
- Final presentation

---

## 🏆 KEY MILESTONES

| Week | Date | Milestone | Status |
|------|------|-----------|--------|
| W2 | 16/3/2026 | ✅ Setup & Planning complete | 🔴 Not Started |
| W3 | 23/3/2026 | ✅ CNPM 1 Testing complete | 🔴 Not Started |
| W5 | 6/4/2026 | ✅ Sprint 1 - New UI complete | 🔴 Not Started |
| W7 | 20/4/2026 | ✅ Sprint 2 - Grades & Tasks complete | 🔴 Not Started |
| W9 | 4/5/2026 | ✅ Sprint 3 - Notes & Export complete | 🔴 Not Started |
| W11 | 18/5/2026 | ✅ Sprint 4 - Security complete | 🔴 Not Started |
| W13 | 1/6/2026 | ✅ Sprint 5 - Polish complete | 🔴 Not Started |
| W14 | 8/6/2026 | ✅ Testing complete, bugs fixed | 🔴 Not Started |
| W15 | 15/6/2026 | 🎉 Final deployment & submission | 🔴 Not Started |

---

## 👥 TEAM ROLES & RESPONSIBILITIES

### Dự án Cá nhân
**Bạn** sẽ làm tất cả:

1. **Project Manager**
   - Sprint planning, task tracking
   - Progress monitoring
   - Timeline management

2. **Full Stack Developer**
   - Backend: Firebase, Firestore
   - Frontend: Flutter UI
   - Integration

3. **UI/UX Designer**
   - Wireframes
   - UI implementation
   - User experience

4. **QA/Tester**
   - Feature testing
   - Bug tracking
   - Quality assurance

5. **Technical Writer**
   - Code documentation
   - User manual
   - Technical report

### Tips cho làm việc một mình:
- ✅ Làm từng feature một, đừng rush
- ✅ Test ngay khi code xong
- ✅ Document trong lúc code
- ✅ Commit code hàng ngày
- ✅ Nghỉ ngơi đầy đủ
- ✅ Hỏi giúp khi cần (Stack Overflow, ChatGPT)

---

## 📦 NEW PACKAGES TO INSTALL

```bash
# Run these commands
flutter pub add table_calendar
flutter pub add fl_chart
flutter pub add google_ml_kit
flutter pub add pdf
flutter pub add share_plus
flutter pub add firebase_database
flutter pub add flutter_staggered_animations
flutter pub add shimmer
flutter pub add lottie
flutter pub add image_picker
flutter pub add image_cropper
```

---

## 🔄 WORKFLOW

### Daily Routine (Cá nhân)
```
Morning:
  ├─ 9:00 AM: Review kế hoạch ngày (15 min)
  ├─ 9:15 AM: Code/Development
  └─ 12:00 PM: Lunch break

Afternoon:
  ├─ 1:00 PM: Development continues
  ├─ 3:00 PM: Testing feature vừa code
  └─ 5:00 PM: Commit code, update progress

Evening (optional):
  └─ Study new technology nếu cần
```

### Weekly Routine
```
Chủ Nhật:
  └─ Review tuần trước, plan tuần tới

Thứ 2-6:
  └─ Focus development

Thứ 7:
  └─ Sprint review (tự review)
  └─ Test tất cả features tuần này
  └─ Update documentation
```

### Git Workflow
```
main (production)
  └─ dev (development)
      ├─ feature/dark-mode
      ├─ feature/grades-module
      └─ bugfix/notification-crash
```

**Process**:
1. Create feature branch from `dev`
2. Develop & test locally
3. Merge to `dev`
4. Test on `dev`
5. When stable → merge to `main`

---

## 📈 PROGRESS TRACKING

### How to Update Status
**Status values**:
- `Not Started` (🔴): Task chưa bắt đầu
- `In Progress` (🟡): Đang làm
- `Testing` (🔵): Đang test
- `Completed` (🟢): Hoàn thành
- `Blocked` (⚫): Bị chặn, cần hỗ trợ

**Process values**: 0%, 25%, 50%, 75%, 100%

### Tools
- **Task Management**: Excel/Google Sheets/Notion
- **Code Repository**: GitHub
- **Documentation**: Markdown files
- **Design**: Figma (free) or paper sketches

---

## ⚠️ RED FLAGS - CẦN CHÚ Ý

1. ❌ Task delay > 3 days so với kế hoạch
2. ❌ Bug không biết cách fix sau 1 ngày research
3. ❌ Mệt mỏi, burnout symptoms
4. ❌ Performance issue nghiêm trọng
5. ❌ Security vulnerability phát hiện
6. ❌ Scope quá lớn, không kịp deadline

**Action**: 
- Pause và đánh giá lại
- Hỏi giúp trên Stack Overflow, forums
- Giảm scope nếu cần
- Ưu tiên sức khỏe

---

## 📋 WEEKLY CHECKLIST

### Hàng tuần
- [ ] Update all task statuses trong CSV
- [ ] Review sprint progress
- [ ] Test features đã code
- [ ] Commit code ít nhất 3-5 lần
- [ ] Update documentation
- [ ] Backup code lên GitHub
- [ ] Plan tuần tiếp theo

---

## 🎓 LEARNING RESOURCES

### For Sprint 1 (UI/UX)
- Material Design 3: https://m3.material.io
- Flutter Animations: https://flutter.dev/docs/development/ui/animations

### For Sprint 2 (Grades & Tasks)
- Firestore Data Modeling: https://firebase.google.com/docs/firestore/data-model
- State Management: https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro

### For Sprint 3 (Collaboration)
- Firebase Realtime DB: https://firebase.google.com/docs/database
- Chat UI Best Practices: https://material.io/design/communication/conversation.html

### For Sprint 4 (AI/ML)
- ML Kit: https://firebase.google.com/docs/ml-kit
- TensorFlow Lite Flutter: https://pub.dev/packages/tflite_flutter

### For Sprint 5 (Security)
- Firebase Security: https://firebase.google.com/docs/rules
- Flutter Security: https://flutter.dev/docs/deployment/android#reviewing-the-app-manifest

---

## 🎉 SUCCESS CRITERIA

### Technical
- ✅ 80%+ high priority features implemented
- ✅ App chạy ổn định
- ✅ App size < 50MB
- ✅ Load time < 3s
- ✅ Zero critical bugs

### Documentation
- ✅ README complete
- ✅ User manual complete
- ✅ Technical report complete
- ✅ Code commented (10%+ lines)

### Deployment
- ✅ Production build successful
- ✅ Testing completed
- ✅ Final presentation ready

### Academic
- ✅ Report submitted on time
- ✅ Demo video prepared
- ✅ Presentation slides ready
- ✅ All deliverables complete

---

## 📞 CONTACT & SUPPORT

**Team Communication**:
- Daily updates: Team chat group
- Urgent issues: Phone/Call
- Code review: GitHub PR comments
- Documentation: Shared drive

**External Resources**:
- Firebase Support: https://firebase.google.com/support
- Flutter Community: https://flutter.dev/community
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**Last Updated**: 3/3/2026  
**Version**: 1.0  
**Next Review**: 16/3/2026 (End of Sprint 0)

---

## 🚀 QUICK START

### Bắt đầu dự án
1. Đọc [CNPM2_TIMELINE.md](CNPM2_TIMELINE.md) để hiểu overview
2. Mở [CNPM2_TASKS.csv](CNPM2_TASKS.csv) trong Excel/Google Sheets
3. Review codebase CNPM 1
4. Bắt đầu với Testing phase (Tuần 3)

### Tuần đầu tiên TODO
- [ ] Review toàn bộ kế hoạch
- [ ] Phân tích requirements
- [ ] Review code CNPM 1
- [ ] Lập danh sách bugs
- [ ] Thiết kế wireframes features mới
- [ ] Setup tracking system

---

**Chúc bạn thành công với Đồ án CNPM 2! 🎓💪**

**Nhớ**: Làm từng bước, test thường xuyên, nghỉ ngơi đầy đủ!
