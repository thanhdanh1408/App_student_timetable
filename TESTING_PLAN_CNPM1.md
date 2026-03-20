# 🧪 KẾ HOẠCH TEST CHI TIẾT - CNPM 1 APP

**Thời gian**: Tuần 3 (17/3/2026 - 23/3/2026)  
**Mục tiêu**: Phát hiện và fix TẤT CẢ bugs trước khi phát triển CNPM 2  
**Phương pháp**: Manual Testing + Exploratory Testing

---

## 📋 OVERVIEW

### Tại sao phải test kỹ trước?
- ✅ Đảm bảo app hiện tại ổn định
- ✅ Phát hiện bugs ẩn
- ✅ Hiểu rõ codebase
- ✅ Tránh build features mới trên nền tảng lỗi
- ✅ Document lại toàn bộ behaviors

### Test Coverage
- 📱 **Authentication**: Login, Register, Logout, Password Reset
- 📚 **Subjects**: CRUD operations
- 📅 **Schedule**: CRUD, conflicts, notifications
- 📝 **Exams**: CRUD, reminders
- 🔔 **Notifications**: Local notifications, permissions
- ⚙️ **Settings**: All settings options
- 🏠 **Home**: Dashboard, navigation

---

## 🗓️ TIMELINE 7 NGÀY

### **Ngày 1 (17/3) - SETUP & AUTHENTICATION**
- Morning: Chuẩn bị môi trường test
- Afternoon: Test authentication flow
- Evening: Document bugs và issues

### **Ngày 2 (18/3) - SUBJECTS & SCHEDULES**
- Morning: Test subjects CRUD
- Afternoon: Test schedules CRUD
- Evening: Test conflicts & edge cases

### **Ngày 3 (19/3) - EXAMS & NOTIFICATIONS**
- Morning: Test exams CRUD
- Afternoon: Test notifications system
- Evening: Test permissions

### **Ngày 4 (20/3) - SETTINGS & HOME**
- Morning: Test settings
- Afternoon: Test home dashboard
- Evening: Integration testing

### **Ngày 5 (21/3) - EDGE CASES & STRESS TEST**
- All day: Edge cases, boundary testing, stress testing

### **Ngày 6 (22/3) - BUG FIXING**
- All day: Fix critical và high priority bugs

### **Ngày 7 (23/3) - REGRESSION & DOCUMENTATION**
- Morning: Regression testing
- Afternoon: Final check
- Evening: Complete documentation

---

## 📱 NGÀY 1: SETUP & AUTHENTICATION (17/3/2026)

### Phase 1: Chuẩn bị môi trường test (1 giờ)

#### 1.1 Tạo Test Tracking Spreadsheet
**File**: `CNPM1_Testing_Results.xlsx`

**Columns**:
```
| Test ID | Feature | Test Case | Steps | Expected Result | Actual Result | Status | Priority | Notes | Screenshot |
```

**Status values**:
- ✅ PASS: Test passed
- ❌ FAIL: Bug found
- ⚠️ WARNING: Minor issue
- 🔄 RETEST: Need retest after fix

**Priority**:
- 🔴 CRITICAL: App crash, data loss
- 🟠 HIGH: Feature không work
- 🟡 MEDIUM: UI issues, minor bugs
- 🟢 LOW: Cosmetic issues

#### 1.2 Setup Test Devices
```
Device 1: Android Phone (your main device)
- OS: [version]
- Screen: [size]
- RAM: [size]

Device 2 (optional): Android Emulator
- Different screen size
- Different Android version

Device 3 (bonus): iOS device/simulator
- Test cross-platform
```

#### 1.3 Tạo Test Data
**Chuẩn bị trước**:
- 3 email test accounts:
  - test1@gmail.com / Test123456
  - test2@gmail.com / Test123456
  - test3@gmail.com / Test123456
- Danh sách môn học để test: ~10 môn
- Danh sách lịch học: ~20 lịch
- Danh sách lịch thi: ~5 lịch thi

#### 1.4 Install Fresh App
```bash
# Clean install
flutter clean
flutter pub get
flutter run --release

# Note app version
Version: [check trong app]
Build: [check build number]
```

---

### Phase 2: Test Authentication Module (2-3 giờ)

#### TEST-AUTH-001: Register New Account
**Priority**: 🔴 CRITICAL

**Pre-condition**: App mới cài, chưa có account

**Test Cases**:

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Register valid account | 1. Open app<br>2. Tap "Đăng ký"<br>3. Enter email: test1@gmail.com<br>4. Enter password: Test123456<br>5. Confirm password: Test123456<br>6. Tap Đăng ký | - Account created<br>- Redirect to home<br>- Show success message | ☐ |
| 1.2 | Register với email đã tồn tại | 1. Tap Đăng ký<br>2. Enter email đã dùng<br>3. Enter password<br>4. Tap Đăng ký | - Show error "Email đã tồn tại"<br>- Stay on register page | ☐ |
| 1.3 | Register với email invalid | 1. Enter: "notanemail"<br>2. Enter password<br>3. Tap Đăng ký | - Show error "Email không hợp lệ"<br>- Không cho register | ☐ |
| 1.4 | Register với password ngắn | 1. Enter valid email<br>2. Enter password: "123"<br>3. Tap Đăng ký | - Show error "Password tối thiểu 6 ký tự" | ☐ |
| 1.5 | Register với password không khớp | 1. Enter email<br>2. Password: "Test123456"<br>3. Confirm: "Test654321"<br>4. Tap Đăng ký | - Show error "Password không khớp" | ☐ |
| 1.6 | Register với empty fields | 1. Leave all fields empty<br>2. Tap Đăng ký | - Show validation errors<br>- Highlight empty fields | ☐ |
| 1.7 | Password visibility toggle | 1. Enter password<br>2. Tap eye icon | - Password show/hide works | ☐ |
| 1.8 | Register khi offline | 1. Turn off internet<br>2. Try register | - Show "Không có kết nối internet"<br>- Graceful error handling | ☐ |

#### TEST-AUTH-002: Login Existing Account
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Login với credentials đúng | 1. Logout if logged in<br>2. Enter correct email<br>3. Enter correct password<br>4. Tap Đăng nhập | - Login successful<br>- Redirect to home<br>- Load user data | ☐ |
| 2.2 | Login với email sai | 1. Enter wrong email<br>2. Enter password<br>3. Tap Đăng nhập | - Show error "Email hoặc password sai" | ☐ |
| 2.3 | Login với password sai | 1. Enter correct email<br>2. Enter wrong password<br>3. Tap Đăng nhập | - Show error "Email hoặc password sai" | ☐ |
| 2.4 | Login với empty fields | 1. Leave fields empty<br>2. Tap Đăng nhập | - Show validation errors | ☐ |
| 2.5 | Remember me checkbox | 1. Check "Remember me"<br>2. Login<br>3. Close app<br>4. Reopen app | - Auto login, no need re-enter | ☐ |
| 2.6 | Login khi offline | 1. Turn off internet<br>2. Try login | - Show internet error<br>- Graceful handling | ☐ |

#### TEST-AUTH-003: Forgot Password
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Request password reset | 1. Tap "Quên mật khẩu?"<br>2. Enter registered email<br>3. Tap Gửi | - Show success message<br>- Email sent (check inbox) | ☐ |
| 3.2 | Request với email không tồn tại | 1. Enter unregistered email<br>2. Tap Gửi | - Show error hoặc<br>- Generic success (security) | ☐ |
| 3.3 | Request với email invalid | 1. Enter invalid format<br>2. Tap Gửi | - Show validation error | ☐ |

#### TEST-AUTH-004: Logout
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Normal logout | 1. Go to Settings<br>2. Tap Đăng xuất<br>3. Confirm | - Logout successful<br>- Clear session<br>- Redirect to login | ☐ |
| 4.2 | Logout confirmation dialog | 1. Tap Đăng xuất | - Show confirmation dialog<br>- Can cancel | ☐ |
| 4.3 | Data persistence after logout | 1. Logout<br>2. Login again | - All data still there<br>- No data loss | ☐ |

#### TEST-AUTH-005: Session Management
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | Auto logout after session expired | 1. Login<br>2. Wait [session timeout]<br>3. Try use app | - Redirect to login if expired | ☐ |
| 5.2 | Multiple device login | 1. Login device 1<br>2. Login device 2 same account | - Both can work (depends on design) | ☐ |
| 5.3 | App background/foreground | 1. Login<br>2. Minimize app 5 min<br>3. Return to app | - Stay logged in<br>- Data still loaded | ☐ |

---

### Phase 3: Document & Report (1 giờ)

#### Checklist cuối ngày
- [ ] Fill tất cả test results vào spreadsheet
- [ ] Screenshot các bugs tìm được
- [ ] List bugs theo priority
- [ ] Estimate effort để fix
- [ ] Plan cho ngày mai

#### Bug Report Template
```markdown
# Bug Report - AUTH-XXX

**Title**: [Short description]

**Priority**: 🔴/🟠/🟡/🟢

**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Result**:
[What should happen]

**Actual Result**:
[What actually happened]

**Screenshots**:
[Attach screenshots]

**Environment**:
- Device: [model]
- OS: [version]
- App version: [version]

**Notes**:
[Additional information]
```

---

## 📚 NGÀY 2: SUBJECTS & SCHEDULES (18/3/2026)

### Phase 1: Test Subjects Module (2-3 giờ)

#### TEST-SUBJ-001: View Subjects List
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | View empty subjects list | 1. New account<br>2. Go to Môn học tab | - Show empty state<br>- Show "Thêm môn học" button<br>- Helpful message | ☐ |
| 1.2 | View subjects list với data | 1. Account có subjects<br>2. Go to Môn học tab | - List all subjects<br>- Show name, credits, room<br>- Smooth scroll | ☐ |
| 1.3 | Search subjects | 1. Enter search term<br>2. Type slowly | - Filter real-time<br>- Highlight matched text | ☐ |
| 1.4 | Sort subjects | 1. Tap sort button<br>2. Select sort option | - Sort by name/credits/etc<br>- Remember sort preference | ☐ |

#### TEST-SUBJ-002: Add New Subject
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Add valid subject | 1. Tap "Thêm môn học"<br>2. Enter name: "Toán Cao Cấp"<br>3. Enter mã môn: "MTH101"<br>4. Credits: 3<br>5. Teacher: "Nguyễn Văn A"<br>6. Room: "A101"<br>7. Tap Lưu | - Subject created<br>- Show in list<br>- Show success toast | ☐ |
| 2.2 | Add với empty required fields | 1. Tap Thêm<br>2. Leave tên môn empty<br>3. Fill other fields<br>4. Tap Lưu | - Show validation error<br>- Highlight empty field<br>- Don't save | ☐ |
| 2.3 | Add với tên môn dài | 1. Enter very long name (100+ chars)<br>2. Fill other fields<br>3. Tap Lưu | - Truncate or limit input<br>- Save successfully or show error | ☐ |
| 2.4 | Add với credits invalid | 1. Enter credits: -1<br>2. Or: 0<br>3. Or: 100 | - Show validation error<br>- Valid range: 1-10? | ☐ |
| 2.5 | Add với special characters | 1. Enter name: "Toán @ #$%"<br>2. Save | - Handle special chars correctly | ☐ |
| 2.6 | Cancel add subject | 1. Tap Thêm<br>2. Fill some fields<br>3. Tap Hủy/Back | - Don't save<br>- Return to list | ☐ |
| 2.7 | Add duplicate subject | 1. Add subject "Toán"<br>2. Add again "Toán" | - Allow or show error?<br>- Check behavior | ☐ |
| 2.8 | Add many subjects | 1. Add 20 subjects | - All save correctly<br>- List scrolls smoothly<br>- No performance issue | ☐ |

#### TEST-SUBJ-003: Edit Subject
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Edit subject name | 1. Tap subject<br>2. Tap Edit<br>3. Change name<br>4. Save | - Updated successfully<br>- Show in list with new name | ☐ |
| 3.2 | Edit all fields | 1. Edit subject<br>2. Change all fields<br>3. Save | - All changes saved | ☐ |
| 3.3 | Edit và cancel | 1. Edit subject<br>2. Change fields<br>3. Tap Cancel | - Changes not saved<br>- Show original data | ☐ |
| 3.4 | Edit với validation error | 1. Edit subject<br>2. Clear required field<br>3. Try save | - Show error<br>- Don't save | ☐ |

#### TEST-SUBJ-004: Delete Subject
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Delete subject | 1. Long press subject<br>2. Tap Delete<br>3. Confirm | - Subject deleted<br>- Removed from list<br>- Show toast | ☐ |
| 4.2 | Delete confirmation | 1. Tap Delete | - Show confirmation dialog<br>- Can cancel<br>- Warning message | ☐ |
| 4.3 | Delete subject có schedules | 1. Subject có lịch học<br>2. Try delete | - Show warning<br>- Ask "Delete schedules too?"<br>- Handle cascade delete | ☐ |
| 4.4 | Delete subject có exams | 1. Subject có lịch thi<br>2. Try delete | - Show warning<br>- Handle properly | ☐ |
| 4.5 | Undo delete | 1. Delete subject<br>2. Look for undo option | - Can undo? (if feature exists)<br>- Or permanent delete | ☐ |

#### TEST-SUBJ-005: Subject Details
**Priority**: 🟡 MEDIUM

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | View subject details | 1. Tap subject | - Show full info<br>- Show schedules for this subject<br>- Show exams for this subject | ☐ |
| 5.2 | Navigate from subject to schedule | 1. View subject<br>2. Tap schedule | - Navigate to schedule detail | ☐ |

---

### Phase 2: Test Schedules Module (2-3 giờ)

#### TEST-SCHED-001: View Schedules
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | View empty schedule | 1. New account<br>2. Go to Lịch học tab | - Show empty state<br>- Show add button | ☐ |
| 1.2 | View schedule list | 1. Account có schedules<br>2. Go to Lịch học | - List all schedules<br>- Group by day/week<br>- Show subject, time, room | ☐ |
| 1.3 | View schedule today | 1. Go to Lịch học<br>2. Check "Hôm nay" | - Show only today's schedules<br>- Highlight current/next class | ☐ |
| 1.4 | View schedule by week | 1. Swipe calendar<br>2. Select different week | - Load schedules for that week<br>- Smooth navigation | ☐ |
| 1.5 | Filter schedule by subject | 1. Select subject filter<br>2. Pick subject | - Show only schedules of that subject | ☐ |

#### TEST-SCHED-002: Add Schedule
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Add valid schedule | 1. Tap Thêm lịch<br>2. Select subject<br>3. Select day: Monday<br>4. Start: 8:00<br>5. End: 10:00<br>6. Room: A101<br>7. Note: "Note"<br>8. Save | - Schedule created<br>- Show in calendar<br>- Notification scheduled | ☐ |
| 2.2 | Add không chọn subject | 1. Tap Thêm<br>2. Don't select subject<br>3. Fill time<br>4. Try save | - Show error "Chọn môn học" | ☐ |
| 2.3 | Add với time invalid | 1. Start: 10:00<br>2. End: 8:00<br>3. (End before start) | - Show error "Thời gian không hợp lệ" | ☐ |
| 2.4 | Add schedule trùng giờ | 1. Add schedule 8-10<br>2. Add another 9-11 same day | - Show conflict warning<br>- Allow or prevent? | ☐ |
| 2.5 | Add recurring schedule | 1. Add schedule<br>2. Select "Lặp lại"<br>3. Choose: Every Monday<br>4. Until: [date] | - Create multiple schedules<br>- Show all in calendar | ☐ |
| 2.6 | Add schedule midnight | 1. Start: 23:00<br>2. End: 01:00 (next day) | - Handle cross-day schedule | ☐ |

#### TEST-SCHED-003: Edit Schedule
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Edit schedule time | 1. Tap schedule<br>2. Edit time<br>3. Save | - Time updated<br>- Notification rescheduled | ☐ |
| 3.2 | Edit schedule subject | 1. Change subject<br>2. Save | - Subject updated | ☐ |
| 3.3 | Edit với conflict | 1. Edit to conflicting time<br>2. Try save | - Show conflict warning | ☐ |
| 3.4 | Edit recurring schedule | 1. Edit schedule từ recurring series<br>2. Options: This one / All | - Handle correctly | ☐ |

#### TEST-SCHED-004: Delete Schedule
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Delete single schedule | 1. Long press<br>2. Delete<br>3. Confirm | - Deleted<br>- Notification cancelled | ☐ |
| 4.2 | Delete recurring schedule | 1. Delete from series<br>2. Options shown | - Delete this / all<br>- Handle properly | ☐ |

#### TEST-SCHED-005: Schedule Notifications
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | Notification permission | 1. First time add schedule | - Ask for notification permission<br>- Handle allow/deny | ☐ |
| 5.2 | Schedule notification | 1. Add schedule 15 min from now<br>2. Wait 15 min | - Notification shows<br>- Correct content<br>- Tap opens app | ☐ |
| 5.3 | Notification settings | 1. Settings > Notifications<br>2. Change reminder time | - Apply to new schedules | ☐ |
| 5.4 | Multiple notifications | 1. Add 5 schedules close together<br>2. Wait | - All notifications show<br>- No missing/duplicate | ☐ |
| 5.5 | Notification khi app killed | 1. Add schedule<br>2. Kill app<br>3. Wait notification time | - Still shows notification<br>- Background service works | ☐ |

---

### Phase 3: Edge Cases & Integration (1 giờ)

#### TEST-INTEG-001: Subjects + Schedules Integration

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Delete subject with schedules | 1. Subject có 5 schedules<br>2. Delete subject | - Show warning<br>- Ask về schedules<br>- Handle cascade | ☐ |
| 1.2 | Edit subject name | 1. Edit subject name<br>2. Check schedules | - Schedules show new name | ☐ |
| 1.3 | Subject color | 1. Set subject color<br>2. Check calendar | - Schedules show that color | ☐ |

---

## 📝 NGÀY 3: EXAMS & NOTIFICATIONS (19/3/2026)

### Phase 1: Test Exams Module (2-3 giờ)

#### TEST-EXAM-001: View Exams
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | View empty exams | 1. New account<br>2. Go to Lịch thi | - Empty state<br>- Add button | ☐ |
| 1.2 | View exams list | 1. Account có exams<br>2. Go to Lịch thi | - List chronologically<br>- Show subject, date, time<br>- Show countdown | ☐ |
| 1.3 | View upcoming exams | 1. Check "Sắp tới" filter | - Only upcoming exams<br>- Sorted by date | ☐ |
| 1.4 | View past exams | 1. Check past exams | - Show past exams<br>- Different styling | ☐ |

#### TEST-EXAM-002: Add Exam
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Add valid exam | 1. Tap Thêm thi<br>2. Select subject<br>3. Date: [future]<br>4. Time: 8:00<br>5. Duration: 90 min<br>6. Room: P101<br>7. Type: Giữa kỳ<br>8. Note: "Note"<br>9. Save | - Exam created<br>- Show in calendar<br>- Reminder scheduled | ☐ |
| 2.2 | Add exam past date | 1. Select past date<br>2. Try save | - Show warning or allow? | ☐ |
| 2.3 | Add exam không chọn subject | 1. Don't select subject<br>2. Try save | - Show validation error | ☐ |
| 2.4 | Add exam không có room | 1. Leave room empty<br>2. Save | - Allow? (room optional?) | ☐ |
| 2.5 | Add multiple exams same day | 1. Add 3 exams same day | - All save correctly<br>- Show warning if overlap? | ☐ |
| 2.6 | Add exam với duration 0 | 1. Duration: 0<br>2. Try save | - Show error<br>- Min duration? | ☐ |

#### TEST-EXAM-003: Edit Exam
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Edit exam date | 1. Tap exam<br>2. Change date<br>3. Save | - Date updated<br>- Reminder rescheduled | ☐ |
| 3.2 | Edit exam time | 1. Change time<br>2. Save | - Time updated | ☐ |
| 3.3 | Edit exam subject | 1. Change subject<br>2. Save | - Subject updated | ☐ |
| 3.4 | Edit past exam | 1. Try edit past exam | - Allow or prevent? | ☐ |

#### TEST-EXAM-004: Delete Exam
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Delete upcoming exam | 1. Long press<br>2. Delete<br>3. Confirm | - Deleted<br>- Reminder cancelled | ☐ |
| 4.2 | Delete past exam | 1. Delete past exam | - Allow delete | ☐ |
| 4.3 | Delete confirmation | 1. Tap delete | - Show confirmation<br>- Can cancel | ☐ |

#### TEST-EXAM-005: Exam Reminders
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | Exam reminder 1 day before | 1. Add exam tomorrow<br>2. Wait until 24h before | - Notification shows<br>- Correct content | ☐ |
| 5.2 | Exam reminder 1 hour before | 1. Wait until 1h before | - Notification shows | ☐ |
| 5.3 | Multiple reminders | 1. Set multiple reminder times | - All show correctly | ☐ |
| 5.4 | Reminder settings | 1. Settings > Exam reminders<br>2. Change timing | - Apply to new exams | ☐ |
| 5.5 | Cancel reminder | 1. Delete exam<br>2. Check notifications | - Reminders cancelled | ☐ |

---

### Phase 2: Test Notifications System (2 giờ)

#### TEST-NOTIF-001: Notification Permissions
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Request permission first time | 1. First schedule/exam add | - Permission dialog shows<br>- Clear message | ☐ |
| 1.2 | Allow permission | 1. Tap Allow | - Permission granted<br>- Notifications work | ☐ |
| 1.3 | Deny permission | 1. Tap Deny | - Show explanation<br>- Guide to settings<br>- App still works | ☐ |
| 1.4 | Check permission status | 1. Settings > Notifications | - Show current status<br>- Link to system settings | ☐ |

#### TEST-NOTIF-002: Notification Display
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Notification appearance | 1. Receive notification | - Clear title<br>- Useful content<br>- App icon<br>- Correct time | ☐ |
| 2.2 | Notification tap | 1. Tap notification | - Opens app<br>- Navigate to relevant screen | ☐ |
| 2.3 | Notification dismiss | 1. Swipe dismiss | - Dismissed<br>- No crash | ☐ |
| 2.4 | Multiple notifications | 1. Multiple show at once | - All visible<br>- Grouped nicely | ☐ |
| 2.5 | Notification sound | 1. Receive notification | - Sound plays<br>- Vibrate works<br>- LED shows (if device has) | ☐ |

#### TEST-NOTIF-003: Notification Settings
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Enable/Disable notifications | 1. Settings > Toggle notifications | - All notifications on/off | ☐ |
| 3.2 | Schedule reminder time | 1. Settings > Set 15 min before | - Apply to new schedules | ☐ |
| 3.3 | Exam reminder times | 1. Set 1 day, 1 hour before | - Both reminders work | ☐ |
| 3.4 | Notification sound | 1. Change notification sound | - New sound plays | ☐ |
| 3.5 | Quiet hours | 1. Set quiet hours 22:00-8:00 | - No notifications in that time | ☐ |

#### TEST-NOTIF-004: Background Notifications
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | App in background | 1. Minimize app<br>2. Wait for notification | - Still shows | ☐ |
| 4.2 | App killed | 1. Kill app<br>2. Wait for notification | - Still shows<br>- Background service works | ☐ |
| 4.3 | Device restart | 1. Add schedule<br>2. Restart device<br>3. Wait | - Notification still scheduled | ☐ |
| 4.4 | Battery optimization | 1. Check if app in battery optimization list | - If yes, may affect notifications<br>- Guide user to disable | ☐ |

#### TEST-NOTIF-005: In-App Notifications
**Priority**: 🟡 MEDIUM

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | View notifications page | 1. Tap Thông báo tab | - List all notifications<br>- Read/Unread status | ☐ |
| 5.2 | Mark as read | 1. Tap notification | - Mark as read<br>- Navigate to item | ☐ |
| 5.3 | Delete notification | 1. Swipe or long press<br>2. Delete | - Removed from list | ☐ |
| 5.4 | Clear all notifications | 1. Tap "Clear all" | - All cleared<br>- Confirmation dialog | ☐ |
| 5.5 | Notification badge | 1. Check app icon | - Badge shows unread count | ☐ |

---

### Phase 3: Integration & Edge Cases (1 giờ)

#### TEST-INTEG-002: Cross-Feature Integration

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Delete subject with exams | 1. Subject có exam<br>2. Delete subject | - Handle exams properly | ☐ |
| 1.2 | Same time schedule & exam | 1. Add both same time | - Show warning?<br>- Both notifications work | ☐ |
| 1.3 | Notification vs app state | 1. Receive notification while in app | - Show toast or in-app alert | ☐ |

---

## ⚙️ NGÀY 4: SETTINGS & HOME (20/3/2026)

### Phase 1: Test Settings Module (2 giờ)

#### TEST-SETT-001: Account Settings
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | View profile | 1. Settings > Profile | - Show email<br>- Show user info | ☐ |
| 1.2 | Edit profile | 1. Tap Edit<br>2. Change name<br>3. Save | - Updated | ☐ |
| 1.3 | Change password | 1. Settings > Change password<br>2. Old password<br>3. New password<br>4. Confirm | - Password changed<br>- Can login with new password | ☐ |
| 1.4 | Change password wrong old | 1. Enter wrong old password<br>2. Try save | - Show error | ☐ |
| 1.5 | Upload profile picture | 1. Tap avatar<br>2. Select image | - Image uploaded<br>- Show in profile | ☐ |

#### TEST-SETT-002: Notification Settings
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Toggle all notifications | 1. Turn off<br>2. Add schedule | - No notification | ☐ |
| 2.2 | Schedule notifications only | 1. Disable exam notifications | - Only schedule notifications work | ☐ |
| 2.3 | Exam notifications only | 1. Disable schedule notifications | - Only exam notifications work | ☐ |
| 2.4 | Change reminder time | 1. Set to 30 min | - Apply to new items | ☐ |
| 2.5 | Custom notification sound | 1. Select sound | - Plays when notification comes | ☐ |

#### TEST-SETT-003: App Settings
**Priority**: 🟡 MEDIUM

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Theme toggle | 1. Settings > Theme<br>2. Switch Light/Dark | - Theme changes immediately<br>- Persist after restart | ☐ |
| 3.2 | Language change | 1. Settings > Language<br>2. Switch language | - All text changes<br>- No missing translations | ☐ |
| 3.3 | Default view | 1. Set default to Calendar | - Opens to calendar on launch | ☐ |
| 3.4 | Week start day | 1. Change to Monday/Sunday | - Calendar adjusts | ☐ |
| 3.5 | Time format | 1. 12h vs 24h | - All times use new format | ☐ |

#### TEST-SETT-004: Data Management
**Priority**: 🔴 CRITICAL

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Backup data | 1. Settings > Backup<br>2. Tap Backup | - Progress shown<br>- Success message<br>- Backup file created | ☐ |
| 4.2 | Restore data | 1. Settings > Restore<br>2. Select file<br>3. Confirm | - Data restored<br>- All subjects/schedules back | ☐ |
| 4.3 | Clear cache | 1. Settings > Clear cache | - Cache cleared<br>- App still works | ☐ |
| 4.4 | Delete all data | 1. Settings > Delete all<br>2. Confirm | - All data deleted<br>- Strong confirmation | ☐ |
| 4.5 | Export data | 1. Export to PDF/Excel | - File generated<br>- Can open file | ☐ |

#### TEST-SETT-005: About & Help
**Priority**: 🟢 LOW

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | View app version | 1. Settings > About | - Show version number<br>- Build info | ☐ |
| 5.2 | Check for updates | 1. Tap Check updates | - Check and show result | ☐ |
| 5.3 | Terms of service | 1. Tap Terms | - Open terms page | ☐ |
| 5.4 | Privacy policy | 1. Tap Privacy | - Open privacy page | ☐ |
| 5.5 | Help/FAQ | 1. Tap Help | - Show FAQ or guide | ☐ |
| 5.6 | Contact support | 1. Tap Contact | - Open email/form | ☐ |

---

### Phase 2: Test Home Dashboard (2 giờ)

#### TEST-HOME-001: Dashboard Display
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | View empty dashboard | 1. New account<br>2. Open home | - Show empty widgets<br>- Add buttons visible | ☐ |
| 1.2 | View dashboard with data | 1. Account có data<br>2. Open home | - Today's schedules<br>- Upcoming exams<br>- Quick stats<br>- Nice layout | ☐ |
| 1.3 | Dashboard refresh | 1. Pull to refresh | - Refresh animation<br>- Data reloads | ☐ |
| 1.4 | Dashboard auto-refresh | 1. Leave app 1 day<br>2. Return | - Data auto-refreshed | ☐ |

#### TEST-HOME-002: Today's Schedule Widget
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Show today's classes | 1. Check home | - List today's schedules<br>- Show time, subject, room<br>- Highlight next class | ☐ |
| 2.2 | No class today | 1. Day no classes | - Show "Không có lịch hôm nay"<br>- Motivational message? | ☐ |
| 2.3 | Past classes | 1. Check afternoon | - Past classes greyed out or hidden | ☐ |
| 2.4 | Tap schedule | 1. Tap schedule item | - Navigate to schedule detail | ☐ |
| 2.5 | Current class indicator | 1. During class time | - Highlight/badge current class | ☐ |

#### TEST-HOME-003: Upcoming Exams Widget
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Show upcoming exams | 1. Check widget | - Next 3-5 exams<br>- Show countdown<br>- Show subject, date | ☐ |
| 3.2 | No upcoming exams | 1. No exams | - Show "Không có lịch thi"<br>- Add button | ☐ |
| 3.3 | Exam today | 1. Exam today | - Highlight specially<br>- Urgent styling | ☐ |
| 3.4 | Tap exam | 1. Tap exam | - Navigate to exam detail | ☐ |
| 3.5 | Countdown accuracy | 1. Check countdown | - Updates correctly<br>- Shows days/hours | ☐ |

#### TEST-HOME-004: Statistics Widget
**Priority**: 🟡 MEDIUM

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Show stats | 1. Check stats | - Total subjects<br>- Total schedules<br>- Total exams<br>- Nice icons | ☐ |
| 4.2 | Tap stat | 1. Tap "X subjects" | - Navigate to subjects page | ☐ |
| 4.3 | Stats update | 1. Add subject<br>2. Check home | - Stats updated | ☐ |

#### TEST-HOME-005: Quick Actions
**Priority**: 🟡 MEDIUM

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 5.1 | Quick add subject | 1. Tap + button<br>2. Select "Môn học" | - Open add subject form | ☐ |
| 5.2 | Quick add schedule | 1. Quick add schedule | - Open add schedule form | ☐ |
| 5.3 | Quick add exam | 1. Quick add exam | - Open add exam form | ☐ |
| 5.4 | FAB menu | 1. Tap floating button | - Show menu options<br>- Smooth animation | ☐ |

---

### Phase 3: Test Navigation (1 giờ)

#### TEST-NAV-001: Bottom Navigation
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Navigate tabs | 1. Tap each tab | - Switch smoothly<br>- No lag<br>- Correct page loads | ☐ |
| 1.2 | Active tab indicator | 1. Check bottom nav | - Active tab highlighted<br>- Clear indicator | ☐ |
| 1.3 | Tab icons | 1. Check icons | - Correct icons<br>- Consistent style | ☐ |
| 1.4 | Back from detail | 1. Open detail<br>2. Tap back | - Return to tab<br>- Maintain scroll position | ☐ |
| 1.5 | Deep link navigation | 1. Open from notification | - Navigate to correct screen | ☐ |

#### TEST-NAV-002: Gestures & Back Navigation
**Priority**: 🟠 HIGH

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | System back button | 1. Navigate deep<br>2. Tap back | - Go back one level | ☐ |
| 2.2 | Back from home | 1. On home<br>2. Tap back | - Show exit confirmation | ☐ |
| 2.3 | Swipe back (iOS) | 1. Swipe right | - Go back | ☐ |
| 2.4 | Double back exit | 1. Home > back > back quickly | - "Press again to exit" | ☐ |

---

## 🔥 NGÀY 5: EDGE CASES & STRESS TEST (21/3/2026)

### Phase 1: Data Edge Cases (2 giờ)

#### TEST-EDGE-001: Boundary Values

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Max length strings | 1. Enter 1000 character name | - Truncate or handle | ☐ |
| 1.2 | Special characters | 1. Test: emoji, unicode, special chars | - Display correctly | ☐ |
| 1.3 | SQL injection attempt | 1. Enter: "'; DROP TABLE--" | - Sanitized, no crash | ☐ |
| 1.4 | XSS attempt | 1. Enter: "<script>alert()</script>" | - Escaped properly | ☐ |
| 1.5 | Max subjects | 1. Add 100+ subjects | - All work<br>- Performance OK | ☐ |
| 1.6 | Max schedules | 1. Add 500+ schedules | - Handle large data | ☐ |
| 1.7 | Far future date | 1. Schedule in year 2099 | - Accept or show error | ☐ |
| 1.8 | Far past date | 1. Schedule in year 1900 | - Reject old dates | ☐ |

#### TEST-EDGE-002: Null & Empty States

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Empty search results | 1. Search "zzzzzz" | - "No results" message | ☐ |
| 2.2 | Null user data | 1. Delete all data<br>2. Use app | - Handle gracefully | ☐ |
| 2.3 | Missing images | 1. Profile no image | - Show default avatar | ☐ |
| 2.4 | Incomplete data | 1. Subject missing fields | - Show placeholder | ☐ |

#### TEST-EDGE-003: Time & Date Edge Cases

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Midnight schedules | 1. Schedule 00:00-01:00 | - Handle correctly | ☐ |
| 3.2 | Cross-day schedule | 1. 23:00-01:00 | - Show on both days? | ☐ |
| 3.3 | Daylight saving time | 1. Schedule during DST change | - Handle time shift | ☐ |
| 3.4 | Leap year | 1. Schedule Feb 29 | - Validate correctly | ☐ |
| 3.5 | Different timezones | 1. Travel to different timezone | - Times adjust? | ☐ |
| 3.6 | Device time change | 1. Change device time<br>2. Check schedules | - Handle properly | ☐ |

---

### Phase 2: Performance & Stress Test (2 giờ)

#### TEST-PERF-001: Load Performance

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | App cold start | 1. Kill app<br>2. Launch<br>3. Time it | - Launch < 3 seconds | ☐ |
| 1.2 | App warm start | 1. Background app<br>2. Return | - Resume < 1 second | ☐ |
| 1.3 | Large data load | 1. 100 subjects, 500 schedules<br>2. Open app | - Smooth, no lag | ☐ |
| 1.4 | Scroll performance | 1. Scroll fast through long list | - 60 FPS<br>- No jank | ☐ |
| 1.5 | Search performance | 1. Search large dataset | - Results < 500ms | ☐ |

#### TEST-PERF-002: Memory Usage

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Memory on idle | 1. Check RAM usage | - < 100MB? | ☐ |
| 2.2 | Memory during use | 1. Use app heavily<br>2. Check RAM | - No memory leak | ☐ |
| 2.3 | Memory after images | 1. Load 100 profile images | - Efficient caching | ☐ |
| 2.4 | Background memory | 1. Minimize app<br>2. Check RAM | - Reduced usage | ☐ |

#### TEST-PERF-003: Battery Usage

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 3.1 | Battery drain | 1. Use app 1 hour<br>2. Check battery | - < 5% drain? | ☐ |
| 3.2 | Background battery | 1. Leave app background overnight | - Minimal drain | ☐ |
| 3.3 | Notification battery | 1. Many notifications | - Efficient | ☐ |

#### TEST-PERF-004: Network Performance

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 4.1 | Slow connection | 1. Throttle to 2G<br>2. Use app | - Still works<br>- Show loading | ☐ |
| 4.2 | No connection | 1. Airplane mode<br>2. Try use app | - Offline features work<br>- Clear error messages | ☐ |
| 4.3 | Connection switch | 1. WiFi to mobile data<br>2. During operation | - Seamless transition | ☐ |
| 4.4 | Data usage | 1. Use app 1 week<br>2. Check data | - Reasonable usage | ☐ |

---

### Phase 3: Stress & Concurrent Testing (1 giờ)

#### TEST-STRESS-001: Rapid Operations

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 1.1 | Rapid taps | 1. Tap button 20 times quickly | - No crash<br>- Handle gracefully | ☐ |
| 1.2 | Rapid navigation | 1. Switch tabs rapidly | - No crash<br>- Smooth | ☐ |
| 1.3 | Rapid CRUD | 1. Add-edit-delete rapidly | - All operations complete | ☐ |
| 1.4 | Spam notification | 1. Create 50 notifications at once | - All delivered | ☐ |

#### TEST-STRESS-002: Concurrent Operations

| ID | Test Case | Steps | Expected Result | Check |
|----|-----------|-------|-----------------|-------|
| 2.1 | Multi-device sync | 1. Login 2 devices<br>2. Both edit data | - Sync properly<br>- No conflicts | ☐ |
| 2.2 | Background + foreground | 1. Download data<br>2. While using app | - Both work | ☐ |

---

## 🐛 NGÀY 6: BUG FIXING (22/3/2026)

### Phase 1: Prioritize Bugs (1 giờ)

#### Bug Triage Process
1. **Review all bugs found** (từ ngày 1-5)
2. **Categorize** by severity
3. **Estimate** fix effort
4. **Plan** fix order

#### Bug Priority Matrix

| Priority | Severity | Examples | Action |
|----------|----------|----------|--------|
| 🔴 P0 | App crash, data loss | - Crash on login<br>- Data deleted | Fix immediately |
| 🟠 P1 | Feature broken | - Can't add subject<br>- Notifications don't work | Fix today |
| 🟡 P2 | Partial functionality | - UI glitch<br>- Slow performance | Fix this week |
| 🟢 P3 | Minor issues | - Typo<br>- Icon ugly | Fix nice to have |

### Phase 2: Fix Critical Bugs (4-5 giờ)

#### Bug Fixing Workflow
```
1. Reproduce bug
   - Follow exact steps
   - Confirm bug exists
   
2. Identify root cause
   - Debug
   - Check logs
   - Add breakpoints
   
3. Fix
   - Write fix
   - Test fix
   - Ensure no side effects
   
4. Verify
   - Test original case
   - Test related cases
   - Regression test
   
5. Document
   - Update bug report
   - Add to changelog
   - Comment code if needed
```

#### Bug Fix Checklist per Bug

- [ ] Bug reproduced
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] Fix tested
- [ ] No new bugs introduced
- [ ] Related features tested
- [ ] Code reviewed (self)
- [ ] Committed with message: "Fix: [bug description]"
- [ ] Bug report updated
- [ ] Changelog updated

### Focus Areas for Fixing

#### Priority 1: Authentication Bugs
- Login issues
- Registration problems
- Session management

#### Priority 2: Data Loss Prevention
- Save operations
- Delete confirmations
- Backup/restore

#### Priority 3: Notifications
- Not showing
- Wrong time
- Duplicate notifications

#### Priority 4: UI Critical Issues
- Crashes
- Freezes
- Navigation problems

---

## ✅ NGÀY 7: REGRESSION & DOCUMENTATION (23/3/2026)

### Phase 1: Regression Testing (3 giờ)

#### What is Regression Testing?
Test lại TẤT CẢ features sau khi fix bugs để đảm bảo không có bug mới.

#### Regression Test Plan

**Quick Smoke Test** (30 minutes):
```
Login ✓
Add 1 subject ✓
Add 1 schedule ✓
Add 1 exam ✓
Check notification ✓
Check home ✓
Settings ✓
Logout ✓
```

**Full Regression Test** (2.5 hours):
- Re-run ALL test cases từ ngày 1-5
- Focus on:
  - Features có bugs đã fix
  - Features liên quan đến bugs
  - Critical paths

#### Regression Testing Checklist

##### Authentication Module
- [ ] Register works
- [ ] Login works
- [ ] Logout works
- [ ] Password reset works
- [ ] Session persists

##### Subjects Module
- [ ] Add subject
- [ ] Edit subject
- [ ] Delete subject
- [ ] View subjects
- [ ] Search subjects

##### Schedules Module
- [ ] Add schedule
- [ ] Edit schedule
- [ ] Delete schedule
- [ ] View schedules
- [ ] Schedule notifications

##### Exams Module
- [ ] Add exam
- [ ] Edit exam
- [ ] Delete exam
- [ ] View exams
- [ ] Exam reminders

##### Notifications
- [ ] Permission granted
- [ ] Notifications show
- [ ] Tap notification works
- [ ] Settings work

##### Settings
- [ ] All settings apply
- [ ] Profile edit works
- [ ] Theme changes
- [ ] Data export/backup

##### Home
- [ ] Dashboard loads
- [ ] Widgets display correctly
- [ ] Navigation works

##### Cross-cutting
- [ ] No crashes
- [ ] No data loss
- [ ] Performance OK
- [ ] UI responsive

---

### Phase 2: Final Testing (1 giờ)

#### Device Testing Matrix

| Device Type | OS Version | Screen Size | Test Status |
|-------------|------------|-------------|-------------|
| Phone 1 | Android 13 | 6.5" | ☐ |
| Phone 2 | Android 11 | 5.5" | ☐ |
| Tablet | Android 12 | 10" | ☐ |
| Emulator | Android 14 | Various | ☐ |

#### Final Check Scenarios

**Scenario 1: New User Journey**
```
1. Install app fresh
2. Register new account
3. Add 3 subjects
4. Add 5 schedules
5. Add 2 exams
6. Enable notifications
7. Customize settings
8. Check all pages
9. Logout & login again

Expected: Smooth experience, no confusion
```

**Scenario 2: Power User Journey**
```
1. Login existing account
2. Quick add 10 schedules
3. Bulk operations
4. Advanced features
5. Export data
6. Import data back

Expected: Efficient, fast
```

**Scenario 3: Edge Case Journey**
```
1. Add maximum data
2. Offline usage
3. App killed & restored
4. Device rotation
5. Background usage
6. Multiple notifications

Expected: Stable, no crash
```

---

### Phase 3: Documentation (2 giờ)

#### Document 1: Test Summary Report

**File**: `CNPM1_Test_Summary_Report.md`

**Template**:
```markdown
# CNPM 1 - Test Summary Report
**Date**: 17/3/2026 - 23/3/2026
**Tester**: [Your name]
**App Version**: [version]

## Executive Summary
- Total test cases: [number]
- Test cases passed: [number] ([%])
- Bugs found: [number]
- Bugs fixed: [number]
- Critical bugs remaining: [number]

## Test Coverage
- ✅ Authentication: 100%
- ✅ Subjects: 100%
- ✅ Schedules: 100%
- ✅ Exams: 100%
- ✅ Notifications: 100%
- ✅ Settings: 100%
- ✅ Home: 100%

## Test Results by Priority
### Critical (P0)
- Found: [number]
- Fixed: [number]
- Remaining: [number]

### High (P1)
- Found: [number]
- Fixed: [number]
- Remaining: [number]

### Medium (P2)
- Found: [number]
- Fixed: [number]
- Remaining: [number]

### Low (P3)
- Found: [number]
- Fixed: [number]
- Remaining: [number]

## Bug Details
[Table of all bugs với ID, description, status, priority]

## Performance Metrics
- App load time: [seconds]
- Memory usage: [MB]
- Battery drain: [%/hour]
- Network usage: [MB]

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

## Conclusion
[Overall conclusion về stability của app]

## Appendix
- Test cases spreadsheet: [link]
- Bug screenshots: [folder]
- Test videos: [folder]
```

---

#### Document 2: Known Issues & Workarounds

**File**: `CNPM1_Known_Issues.md`

**Template**:
```markdown
# Known Issues - CNPM 1

## Critical Issues (Must Fix)
### ISSUE-001: [Title]
**Description**: [details]
**Impact**: [High/Medium/Low]
**Workaround**: [If any]
**Status**: [Open/In Progress/Fixed]

## Non-Critical Issues (Can Live With)
### ISSUE-XXX: [Title]
[Similar format]

## Feature Limitations
1. [Limitation 1]
2. [Limitation 2]

## Future Enhancements (CNPM 2)
1. [Enhancement 1]
2. [Enhancement 2]
```

---

#### Document 3: Changelog

**File**: `CHANGELOG_CNPM1_Testing.md`

**Template**:
```markdown
# Changelog - Testing Phase

## [Unreleased]

### Fixed
- Bug #001: [description]
- Bug #002: [description]

### Changed
- [Improvement 1]
- [Improvement 2]

### Known Issues
- [Issue 1]
- [Issue 2]

## [Version before testing]

### Features
- Authentication
- Subjects management
- Schedule management
- Exam management
- Notifications
- Settings
```

---

#### Document 4: Test Data

**File**: `Test_Data_Used.md`

**Document test accounts và data used**:
```markdown
# Test Accounts
1. test1@gmail.com / Test123456
2. test2@gmail.com / Test123456

# Test Subjects
1. Toán Cao Cấp - MTH101
2. Lập Trình Mobile - CS201
[etc...]

# Test Schedules
[List schedules created]

# Test Exams
[List exams created]
```

---

#### Document 5: Lessons Learned

**File**: `Lessons_Learned.md`

**Reflect on testing process**:
```markdown
# Lessons Learned - Testing CNPM 1

## What Went Well
1. [Good thing 1]
2. [Good thing 2]

## What Didn't Go Well
1. [Issue 1]
2. [Issue 2]

## What I Learned
1. [Learning 1]
2. [Learning 2]

## Process Improvements
1. [Improvement 1]
2. [Improvement 2]

## Tips for CNPM 2 Testing
1. [Tip 1]
2. [Tip 2]
```

---

## 📊 TRACKING & METRICS

### Daily Progress Tracking

**File**: `Daily_Testing_Log.xlsx`

**Columns**:
```
Date | Hours | Test Cases Run | Pass | Fail | Bugs Found | Bugs Fixed | Notes
```

**Example**:
```
17/3 | 8h | 45 | 40 | 5 | 5 | 0 | Authentication module
18/3 | 8h | 60 | 55 | 5 | 5 | 0 | Subjects & Schedules
19/3 | 8h | 50 | 45 | 5 | 5 | 0 | Exams & Notifications
20/3 | 8h | 40 | 38 | 2 | 2 | 0 | Settings & Home
21/3 | 8h | 30 | 25 | 5 | 5 | 0 | Edge cases
22/3 | 8h | 0  | 0  | 0 | 0 | 15 | Bug fixing
23/3 | 8h | 100| 95 | 5 | 0 | 5 | Regression
```

---

### Test Metrics Dashboard

#### Coverage Metrics
```
Total Features: 7
Features Tested: 7 (100%)

Total Test Cases: ~300
Test Cases Executed: [number]
Pass Rate: [%]
```

#### Bug Metrics
```
Total Bugs: [number]
Critical: [number]
High: [number]
Medium: [number]
Low: [number]

Fixed: [number] ([%])
Remaining: [number]
```

#### Time Metrics
```
Time Estimated: 56 hours (7 days × 8h)
Time Actual: [hours]
Variance: [hours]

Breakdown:
- Testing: [hours]
- Bug fixing: [hours]
- Documentation: [hours]
```

---

## 🎯 SUCCESS CRITERIA

### App is Ready for CNPM 2 Development When:

#### Must Have (Blocking)
- [ ] ❌ Zero critical (P0) bugs
- [ ] ❌ Zero high (P1) bugs that block functionality
- [ ] ✅ All authentication works
- [ ] ✅ All CRUD operations work
- [ ] ✅ Notifications work reliably
- [ ] ✅ No app crashes in normal usage
- [ ] ✅ No data loss scenarios

#### Should Have (Important)
- [ ] Medium bugs < 5
- [ ] Low bugs < 10
- [ ] Performance acceptable
- [ ] UI reasonably polished
- [ ] All documentation complete

#### Nice to Have
- [ ] Zero bugs (all fixed)
- [ ] Performance optimized
- [ ] UI perfect
- [ ] All edge cases handled

---

## 🛠️ TOOLS & RESOURCES

### Testing Tools

#### Manual Testing
- **Device**: Your Android phone
- **Emulator**: Android Studio emulator
- **Screen recorder**: AZ Screen Recorder (Play Store)
- **Screenshot**: Built-in device tool
- **Notes**: Google Keep / Notion

#### Tracking Tools
- **Spreadsheet**: Excel / Google Sheets (CNPM1_Testing_Results.xlsx)
- **Bug tracking**: Same spreadsheet or Trello board
- **Documentation**: Markdown files in repo

#### Helpful Commands
```bash
# Check app logs
flutter logs

# Clear app data
flutter clean
flutter pub get

# Run in debug mode with logs
flutter run --verbose

# Build release version
flutter build apk --release

# Check app size
flutter build apk --analyze-size

# Get device info
adb devices
adb shell getprop ro.build.version.release
```

---

## 📋 CHEAT SHEET

### Quick Test Checklist (15 mins)
```
☐ Login
☐ Add subject
☐ Add schedule
☐ Add exam  
☐ Check notification permission
☐ Navigate all tabs
☐ Check settings
☐ Logout & login
```

### Critical Path Test (30 mins)
```
☐ Full authentication flow
☐ Complete CRUD for subjects
☐ Complete CRUD for schedules
☐ Complete CRUD for exams
☐ Verify notifications work
☐ Test settings apply
☐ Test data persists
```

### Before Ending Each Day
```
☐ Update test results spreadsheet
☐ Screenshot all bugs found
☐ Write bug reports
☐ Commit code if fixed bugs
☐ Plan tomorrow's tasks
☐ Backup test data
```

---

## 💡 TESTING TIPS

### General Tips
1. **Test như user thực sự** - Don't just test happy path
2. **Document ngay** - Don't rely on memory
3. **Screenshot everything** - Evidence is important
4. **One bug = One report** - Don't bundle
5. **Retest after fix** - Verify fix works

### Finding Bugs
1. **Think negative** - Try to break the app
2. **Use edge values** - Min, max, null, empty
3. **Try wrong inputs** - Invalid data
4. **Test interruptions** - Phone call, SMS during usage
5. **Test state changes** - Offline, background, etc

### Avoiding Fatigue
1. **Take breaks** - 5 min break every hour
2. **Vary testing** - Switch between modules
3. **Set goals** - X test cases per hour
4. **Celebrate finds** - Finding bugs is success!
5. **Don't rush** - Quality over quantity

### Efficiency
1. **Prepare test data** beforehand
2. **Use copy-paste** for repetitive text
3. **Take notes** in real-time
4. **Use templates** for bug reports
5. **Batch similar tests** together

---

## ❓ FAQ

### Q: Tìm được bao nhiêu bugs là đủ?
**A**: Không có con số cụ thể. Mục tiêu là tìm TẤT CẢ bugs nghiêm trọng. Typically 10-30 bugs là normal cho app size này.

### Q: Phải fix tất cả bugs không?
**A**: Critical (P0) và High (P1) phải fix. Medium và Low có thể để CNPM 2.

### Q: Không tìm được bug nào, tốt hay xấu?
**A**: Unlikely. Có thể app rất tốt, hoặc bạn test chưa kỹ. Test cả edge cases và negative scenarios.

### Q: Bug quá nhiều, không fix kịp?
**A**: Prioritize! Fix Critical first, High next. Document các bugs còn lại cho CNPM 2.

### Q: Làm sao biết đã test đủ kỹ?
**A**: Khi bạn confident deploy app cho users thật mà không lo crash hay mất data.

### Q: Test trên emulator hay device thật?
**A**: CẢ HAI. Emulator tiện, nhưng device thật chính xác hơn, đặc biệt notifications.

### Q: Cần người khác test giúp không?
**A**: Nếu có thì tốt (fresh perspective), nhưng bạn phải tự test kỹ trước.

---

## ✅ FINAL CHECKLIST

### Before Starting Testing (17/3)
- [ ] Read toàn bộ kế hoạch này
- [ ] Setup test tracking spreadsheet
- [ ] Prepare test devices
- [ ] Create test accounts
- [ ] Install fresh build
- [ ] Clear schedule for 7 days

### During Testing (17-23/3)
- [ ] Follow day-by-day plan
- [ ] Document everything
- [ ] Take screenshots
- [ ] Update tracking regularly
- [ ] Fix critical bugs immediately

### After Testing (23/3 evening)
- [ ] All test cases executed
- [ ] All critical bugs fixed
- [ ] Test summary report written
- [ ] Known issues documented
- [ ] Changelog updated
- [ ] Code committed
- [ ] Ready for CNPM 2!

---

## 🎉 MOTIVATION

**Remember**:
- Testing là foundation cho CNPM 2
- Mỗi bug tìm được là save time sau này
- App stable = happy coding trong CNPM 2
- Bạn đang làm tốt! Keep going! 💪

**Quote**:
> "Testing shows the presence, not the absence of bugs" - Dijkstra

But we're trying our best! 🚀

---

**Good luck với testing! Nếu có thắc mắc, refer back to kế hoạch này! 📚**

**Document Version**: 1.0  
**Created**: 10/3/2026  
**For**: CNPM 1 Testing Phase (Week 3)
