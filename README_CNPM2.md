# 📚 ĐỒ ÁN CNPM 2 - TÀI LIỆU HƯỚNG DẪN

## Tổng quan tài liệu

Chào mừng bạn! Đây là bộ tài liệu hoàn chỉnh để phát triển phiên bản 2.0 của Student Timetable App.

**Loại hình**: Dự án cá nhân (1 người)
**Thời gian**: 15 tuần

---

## 📄 Các file tài liệu đã tạo

### 1. **CNPM2_TIMELINE.md** - Tài liệu chi tiết nhất 📋
**Mục đích**: Kế hoạch chi tiết đầy đủ  
**Nội dung**:
- Timeline 15 tuần đầy đủ
- 56 tasks được chia theo Sprint
- Mô tả chi tiết từng task
- Phân công vai trò
- Packages cần cài đặt
- Risk mitigation
- Success metrics

**Khi nào đọc**: 
- ✅ Team Leader cần overview toàn bộ dự án
- ✅ Lần đầu tiên tham gia dự án
- ✅ Lập kế hoạch chi tiết cho Sprint

---

### 2. **CNPM2_TASKS.csv** - File Excel/CSV tracking ✅
**Mục đích**: Theo dõi tiến độ hàng ngày  
**Nội dung**:
- Danh sách 56 tasks dạng bảng
- Cột: Sprint, TaskDetail, Status, Process, Who, DateBegin, Deadline, Priority, Note
- Có thể import vào Excel, Google Sheets, Trello, Jira

**Khi nào dùng**:
- ✅ Hàng ngày để update status
- ✅ Import vào tool quản lý dự án
- ✅ Tracking tiến độ cá nhân

**Cách dùng**:
```bash
# Mở bằng Excel
Open in Excel → Có thể filter, sort, create charts

# Hoặc import vào Google Sheets
File → Import → Upload file

# Hoặc import vào Trello/Jira
Tùy tool, có chức năng import CSV
```

---

### 3. **CNPM2_QUICK_REFERENCE.md** - Cẩm nang nhanh 📖
**Mục đích**: Tra cứu nhanh mọi thông tin quan trọng  
**Nội dung**:
- Project overview
- Sprint summary
- Team roles
- Weekly checklist
- Workflow guide
- Success criteria
- Learning resources

**Khi nào đọc**:
- ✅ Cần tra cứu nhanh thông tin
- ✅ Onboarding thành viên mới
- ✅ Nhắc nhở công việc hàng tuần

---

### 4. **CNPM2_GANTT.md** - Gantt Chart trực quan 📊
**Mục đích**: Visualize timeline và dependencies  
**Nội dung**:
- ASCII Gantt chart view
- Dependencies map
- Resource allocation
- Critical path analysis
- Parallel work streams
- Risk timeline

**Khi nào đọc**:
- ✅ Hiểu overview về thời gian
- ✅ Xem task nào phụ thuộc task nào
- ✅ Present cho stakeholder

---

## 🎯 Cách sử dụng tài liệu này

### Cá nhân - Làm một mình
```
Tuần 1:
├─ Đọc kỹ CNPM2_TIMELINE.md toàn bộ
├─ Mở CNPM2_TASKS.csv trong Excel/Google Sheets
├─ Tạo folder cho documents và notes
├─ Review code CNPM 1
└─ Lập kế hoạch chi tiết

Hàng tuần:
├─ Check CNPM2_TASKS.csv để xem progress
├─ Update status các task đã làm
├─ Làm theo timeline trong CNPM2_TIMELINE.md
└─ Review và adjust nếu cần

Hàng ngày:
├─ Check task hôm nay trong CSV
├─ Code, test, document
├─ Update Process % khi làm
├─ Commit code lên GitHub
└─ Mark Completed khi xong

Khi gặp khó:
└─ Xem CNPM2_QUICK_REFERENCE.md
└─ Search Stack Overflow, ChatGPT
└─ Read documentation
```

---

## 📊 Recommended Tools Stack

### Project Management (Cá nhân)
**Option 1: Excel/Google Sheets (Simple)**
```
File: CNPM2_TASKS.csv
- Mở trong Excel/Google Sheets
- Filter, sort theo Sprint/Priority
- Update Status và Process
- Color coding: Red (Not Started), Yellow (In Progress), Green (Completed)
```

**Option 2: Notion (Recommended)**
```
Database: Tasks
Views:
├─ Table view (like CSV)
├─ Calendar view (by Deadline)
├─ Board view (by Status)
└─ Timeline view (Gantt)

Link tất cả documents trong 1 workspace
```

### Development
```
Version Control: Git + GitHub
Code Editor: VS Code
Testing: Flutter Test
Design: Figma (free) or paper sketches
```

---

## 🚀 Action Items - First Week

### Tuần 1 (3/3 - 9/3/2026)

#### Day 1 (3/3/2026) - Phân tích
```
□ Đọc CNPM2_TIMELINE.md toàn bộ (1-2 giờ)
□ Skim CNPM2_QUICK_REFERENCE.md (30 phút)
□ Mở CNPM2_TASKS.csv trong Excel
□ Tạo lịch làm việc cá nhân
```

#### Day 2-3 (4-5/3/2026) - Review Code
```
□ Review toàn bộ code CNPM 1
□ Chạy và test app hiện tại
□ Liệt kê bugs tìm được
□ Xác định features cần improve
```

#### Day 4-5 (6-7/3/2026) - Thiết kế
```
□ Thiết kế database schema cho features mới
□ Sketch wireframes (paper or Figma)
□ Lập danh sách packages cần cài
```

#### Tuần 2 (10/3 - 16/3/2026) - Kế hoạch
```
□ Lập kế hoạch chi tiết cho từng Sprint
□ Adjust timeline nếu cần
□ Setup Git repository structure
□ Chuẩn bị bắt đầu Tuần 3 (Testing phase)
```

---

## 📋 Weekly Status Report Template

**Sử dụng template này để báo cáo hàng tuần:**

```markdown
# Weekly Status Report - Week [số]
**Date**: [startDate] - [endDate]
**Reporter**: [Tên]

## 📊 Overall Progress
- Planned tasks this week: [số]
- Completed tasks: [số]
- In Progress tasks: [số]
- Blocked tasks: [số]
- Completion rate: [%]

## ✅ Completed This Week
1. [Task name] - [Who] - [Date completed]
2. ...

## 🔄 In Progress
1. [Task name] - [Who] - [Progress %] - [Expected completion]
2. ...

## 🚧 Blockers
1. [Description] - [Impact] - [Need help from whom]
2. ...

## 📅 Plan for Next Week
1. [Task name] - [Assigned to]
2. ...

## 📈 Metrics
- Code commits: [số]
- PRs merged: [số]
- Bugs fixed: [số]
- Test coverage: [%]

## 💭 Notes
[Any other important notes]

---
**Next Meeting**: [Date & Time]
```

---

## ⚠️ Important Reminders

### DO's ✅
- ✅ Commit code frequently (daily)
- ✅ Write tests với code mới
- ✅ Document rõ ràng
- ✅ Code review nghiêm túc
- ✅ Update task status daily
- ✅ Communicate blockers immediately
- ✅ Ask questions when stuck
- ✅ Follow coding standards

### DON'Ts ❌
- ❌ Push code trực tiếp vào main branch
- ❌ Skip testing
- ❌ Ignore code review comments
- ❌ Work in isolation (communicate!)
- ❌ Leave broken code overnight
- ❌ Hardcode sensitive data (API keys, passwords)
- ❌ Copy code without understanding
- ❌ Postpone documentation to the end

---

## 🎓 Success Tips from Previous Projects

### 1. Communication is Key
```
"The project failed not because of technical issues,
but because team members didn't communicate."
```
→ Over-communicate rather than under-communicate

### 2. Test Early, Test Often
```
"We spent Week 14 fixing bugs that could have been
caught with proper testing in Week 3-13."
```
→ Write tests as you develop

### 3. Document as You Go
```
"In Week 15, nobody remembered why certain decisions
were made because we didn't document."
```
→ Update README, comments, and docs continuously

### 4. Code Review is Not Optional
```
"A critical bug went to production because only one
person reviewed the code."
```
→ Require 2+ approvals on critical PRs

### 5. Prioritize Ruthlessly
```
"We tried to implement everything and ended up with
nothing working well."
```
→ Focus bản chiếc có MVP trước, enhancement sau

---

## 📞 Emergency Contacts (EXAMPLE)

**Thay đổi theo team của bạn:**

```
Team Leader: [Tên] - [Phone] - [Email]
Tech Lead: [Tên] - [Phone] - [Email]

Backend Lead: [Tên] - [Email]
Frontend Lead: [Tên] - [Email]
QA Lead: [Tên] - [Email]

Emergency Escalation:
Critical Bug → Tech Lead (immediate)
Blocker > 1 day → Team Leader (daily standup)
Team Conflict → Team Leader (private message)
Technical Decision → Tech Lead + Team Leader (meeting)
```

---

## 🎯 Definition of Done

**Một task được coi là DONE khi:**

```
□ Code implemented và working
□ Tested manually (chạy thử trên app)
□ No obvious bugs
□ Code commented ở phần phức tạp
□ Committed to Git
□ Task status updated trong CSV
□ Feature work as expected
```

---

## 📚 Additional Resources

### Internal Documents
- `README.md` - Project overview
- `docs/architecture.md` - System architecture (tạo sau)
- `docs/api.md` - API documentation (tạo sau)
- `CONTRIBUTING.md` - Contribution guidelines (tạo sau)

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design Guidelines](https://material.io/design)
- [Git Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

---

## 🔄 Document Updates

**Các file này cần được cập nhật:**

### CNPM2_TASKS.csv
- **Frequency**: Daily
- **Who**: All team members (own tasks)
- **What**: Status, Process %

### CNPM2_TIMELINE.md
- **Frequency**: Weekly or when major changes
- **Who**: Team Leader
- **What**: Adjustments to timeline, new tasks

### CNPM2_QUICK_REFERENCE.md
- **Frequency**: When significant changes
- **Who**: Tech Lead + Team Leader
- **What**: New processes, updated contacts

### CNPM2_GANTT.md
- **Frequency**: After each Sprint
- **Who**: Team Leader
- **What**: Actual vs planned timeline

### README_CNPM2.md (this file)
- **Frequency**: As needed
- **Who**: Team Leader
- **What**: Process improvements, new sections

---

## 📊 Key Performance Indicators (KPIs)

**Theo dõi các metrics này:**

### Development KPIs
```
Velocity: [số] story points/sprint
Commit frequency: [số] commits/day/developer
Code review time: [hours] average
PR merge time: [hours] average
Build success rate: [%]
```

### Quality KPIs
```
Test coverage: [%] (Target: 80%+)
Bug density: [số] bugs/1000 LOC
Critical bugs: [số] (Target: 0)
Code review coverage: [%] (Target: 100%)
```

### Team KPIs
```
Sprint completion rate: [%] (Target: 90%+)
On-time delivery: [%] (Target: 95%+)
Blocker resolution time: [hours] average
Meeting attendance: [%]
```

---

## 🎉 Milestones & Celebrations

**Đừng quên celebrate thành công!**

```
✅ End of Setup (Week 2)
   └─ 🎉 Thưởng bản thân 1 ly cafe ngon

✅ Testing CNPM 1 Complete (Week 3)
   └─ 🎉 App ổn định, ready cho phát triển

✅ Sprint 1 Complete (Week 5)
   └─ 🎉 UI mới đẹp, dark mode works!

✅ Sprint 2 Complete (Week 7)
   └─ 🎉 Grades và Tasks hoàn thành

✅ Mid-project (Week 9)
   └─ 🎉 50% rồi! Nghỉ 1 ngày đi chơi

✅ Sprint 4 Complete (Week 11)
   └─ 🎉 Security & Performance tốt

✅ All Sprints Done (Week 13)
   └─ 🎉 All features hoàn thành!

✅ Testing Complete (Week 14)
   └─ 🎉 App chạy ổn định

✅ Final Submission (Week 15)
   └─ 🎉🎉🎉 PROJECT COMPLETE! Cực kỳ tự hào!
```

---

## 📝 Feedback & Improvements

**Tài liệu này sẽ improve dựa trên feedback:**

```
Nếu bạn có suggestions:
├─ Create GitHub Issue
├─ Discuss trong retrospective meeting
└─ Message Team Leader

Questions?
└─ Add to FAQ section below
```

---

## ❓ FAQ (Frequently Asked Questions)

### Q1: Timeline có thể thay đổi không?
**A**: Có! Timeline này là đề xuất. Bạn có thể adjust based on tiến độ thực tế. Linh hoạt nhưng cố gắng giữ deadline chính.

### Q2: Nếu một task mất nhiều thời gian hơn estimate?
**A**: 
1. Đánh giá lại task
2. Chia nhỏ ra nếu cần
3. Adjust timeline các task sau
4. Hoặc skip features Low priority

### Q3: Testing có bắt buộc không?
**A**: Yes cho features chính. Không cần unit test phức tạp, nhưng phải test manually kỹ.

### Q4: Làm gì nếu stuck > 1 ngày?
**A**: 
1. Search Stack Overflow
2. Hỏi ChatGPT/Claude
3. Đọc documentation
4. Hỏi trong Flutter group
5. Skip tạm và quay lại sau

### Q5: Features nào là bắt buộc?
**A**: 
Must Have:
- Testing CNPM 1
- Dark mode
- Calendar view
- Grades management
- Tasks/To-Do
- Security
- Performance

Nice to Have:
- Notes
- Export PDF
- Widget
- i18n

### Q6: Có cần AI/ML features không?
**A**: KHÔNG bắt buộc. Đó là optional và khá advanced. Focus vào core features trước.

### Q7: Bao nhiêu giờ/ngày nên làm?
**A**: 6-8 giờ/ngày là hợp lý. Đừng overwork! Nghỉ ngơi quan trọng.

### Q8: Deploy như thế nào?
**A**: Build APK file bằng `flutter build apk --release`. Test trên điện thoại thật.

---

## 📅 Important Dates Summary

```
3/3/2026  : 🚀 Project Kickoff
16/3/2026 : ✅ Sprint 0 Complete (Setup)
30/3/2026 : ✅ Sprint 1 Complete (UI/UX)
13/4/2026 : ✅ Sprint 2 Complete (Grades/Tasks)
27/4/2026 : ✅ Sprint 3 Complete (Collaboration)
11/5/2026 : ✅ Sprint 4 Complete (AI/ML)
25/5/2026 : ✅ Sprint 5 Complete (Security)
1/6/2026  : ✅ Sprint 6 Complete (Additional)
8/6/2026  : ✅ Testing Complete
15/6/2026 : 🎉 FINAL SUBMISSION
```

---

## 🌟 Final Words

```
"Quality is not an act, it is a habit."
- Aristotle

"The best way to predict the future is to create it."
- Peter Drucker
```

**Chúc team thành công với Đồ án CNPM 2! 🚀**

Hãy nhớ:
- Code với passion ❤️
- Test với discipline 🧪
- Document với care 📝
- Communicate với clarity 💬
- Collaborate với respect 🤝

**Let's build something amazing together!**

---

**Document Created**: 3/3/2026  
**Version**: 1.0  
**Maintained By**: Team Leader  
**Last Updated**: 3/3/2026  
**Next Review**: 16/3/2026

---

© 2026 Student Timetable App - CNPM 2 Project
