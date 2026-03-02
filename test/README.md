// test/README.md
# Test Documentation

## 📁 Cấu trúc Test

```
test/
├── unit/                          # Unit tests (80% coverage)
│   ├── domain/
│   │   ├── entities/             # Test entities
│   │   └── usecases/             # Test use cases
│   └── presentation/
│       └── viewmodels/           # Test view models
├── integration/                   # Integration tests (60% coverage)
│   └── features/                 # Test toàn bộ feature flow
├── widget/                        # Widget tests (40% coverage)
│   └── [TBD]
└── e2e/                          # End-to-end tests (20% coverage)
    └── [TBD]
```

## 🧪 Loại Test

### 1. Unit Tests
Kiểm tra từng component riêng lẻ:
- **Entities**: Test data models, JSON parsing, copyWith
- **UseCases**: Test business logic đơn giản
- **ViewModels**: Test state management, data flow

**Ví dụ:**
```bash
flutter test test/unit/domain/entities/subject_entity_test.dart
flutter test test/unit/domain/usecases/subjects_usecases_test.dart
flutter test test/unit/presentation/viewmodels/subjects_viewmodel_test.dart
```

### 2. Integration Tests
Kiểm tra nhiều components cùng hoạt động:
- Repository → UseCase → ViewModel
- Complete user flows
- Error propagation

**Ví dụ:**
```bash
flutter test test/integration/features/subjects_integration_test.dart
```

### 3. Widget Tests (Sẽ thêm)
Kiểm tra UI components:
- Forms validation
- Button interactions
- Navigation

### 4. E2E Tests (Sẽ thêm)
Kiểm tra toàn bộ app:
- User journeys
- Real device testing

## 🚀 Chạy Tests

### Chạy tất cả tests:
```bash
flutter test
```

### Chạy tests với coverage:
```bash
flutter test --coverage
```

### Xem coverage report:
```bash
# Windows
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html

# macOS/Linux
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Chạy một file test cụ thể:
```bash
flutter test test/unit/domain/entities/subject_entity_test.dart
```

### Chạy tests theo pattern:
```bash
flutter test --name "SubjectEntity"
flutter test --name "should load subjects"
```

## 📊 Kết Quả Hiện Tại

### Unit Tests
- ✅ `subject_entity_test.dart` - 6/6 tests passed
- ✅ `subjects_usecases_test.dart` - 12/12 tests passed  
- ✅ `subjects_viewmodel_test.dart` - 15/15 tests passed

### Integration Tests
- ✅ `subjects_integration_test.dart` - 8/8 tests passed

**Tổng: 41 tests - Tất cả PASSED ✅**

## 🔧 Setup

### Cài đặt dependencies:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

### Generate mock classes:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📝 Test Cases Coverage

### Subjects Feature: ✅ 100%
- [x] Entity creation and validation
- [x] JSON serialization/deserialization
- [x] Repository operations (CRUD)
- [x] UseCase execution
- [x] ViewModel state management
- [x] Error handling
- [x] Search functionality
- [x] Loading states
- [x] Edge cases

### Schedule Feature: ⏳ Pending
- [ ] Entity tests
- [ ] UseCase tests
- [ ] ViewModel tests
- [ ] Integration tests

### Exam Feature: ⏳ Pending
- [ ] Entity tests
- [ ] UseCase tests
- [ ] ViewModel tests
- [ ] Integration tests

### Notifications Feature: ⏳ Pending
- [ ] Entity tests
- [ ] UseCase tests
- [ ] ViewModel tests
- [ ] Integration tests

### Authentication Feature: ⏳ Pending
- [ ] Entity tests
- [ ] UseCase tests
- [ ] ViewModel tests
- [ ] Integration tests

## ✨ Best Practices

### 1. Test Naming
```dart
test('should [expected behavior] when [condition]', () {});
```

### 2. AAA Pattern (Arrange-Act-Assert)
```dart
test('example', () {
  // Arrange - Setup
  final input = 'test';
  
  // Act - Execute
  final result = function(input);
  
  // Assert - Verify
  expect(result, expectedOutput);
});
```

### 3. Mock External Dependencies
```dart
@GenerateMocks([Repository])
late MockRepository mockRepository;

setUp(() {
  mockRepository = MockRepository();
});
```

### 4. Test Edge Cases
- Null values
- Empty lists
- Very long strings
- Concurrent operations
- Network errors
- Validation errors

## 🐛 Debugging Tests

### Chạy test với verbose:
```bash
flutter test --reporter expanded
```

### Debug một test:
Thêm debugger trong test:
```dart
test('debug example', () {
  debugger(); // Breakpoint
  expect(result, expected);
});
```

## 📈 Coverage Goals

- **Unit Tests**: 80%+
- **Integration Tests**: 60%+
- **Widget Tests**: 40%+
- **E2E Tests**: 20%+

## 🔜 Next Steps

1. ✅ Subjects feature tests - DONE
2. ⏳ Schedule feature tests - IN PROGRESS
3. ⏳ Exam feature tests
4. ⏳ Notifications feature tests
5. ⏳ Authentication feature tests
6. ⏳ Widget tests cho forms
7. ⏳ E2E tests cho critical flows

## 📚 Resources

- [Flutter Testing Docs](https://flutter.dev/docs/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Test Coverage](https://pub.dev/packages/coverage)

---

**Last Updated:** 14/01/2026
**Test Status:** 41 tests passing ✅
