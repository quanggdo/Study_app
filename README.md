# Student Academic Assistant (SAA)

Student Academic Assistant là ứng dụng Flutter hỗ trợ sinh viên quản lý học tập theo hướng AI-first và mobile-first. Tài liệu này mô tả trạng thái triển khai hiện tại của dự án theo code thực tế.

## 1) Mục tiêu sản phẩm

- Quản lý công việc học tập theo deadline và nhắc nhở cục bộ.
- Tạo ghi chú học tập từ giọng nói hoặc file audio bằng ASR + Gemini.
- Nhập và quản lý thời khóa biểu bằng OCR/AI.
- Hỗ trợ ôn tập qua Quiz, Flashcard, Pomodoro.
- Duy trì giao diện hiện đại, đồng bộ Light/Dark mode.

## 2) Công nghệ đang dùng

### 2.1 Framework và kiến trúc

- Flutter (Dart SDK >= 3.3.0)
- Kiến trúc Feature-first + MVVM
- State management: Riverpod
- Routing: GoRouter

### 2.2 Backend và dữ liệu

- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Cloud Functions
- Firebase Messaging

### 2.3 AI và xử lý media

- Gemini qua gói google_generative_ai
- OCR: google_mlkit_text_recognition
- ASR realtime: speech_to_text
- Chọn file audio: file_picker
- Camera/Gallery: image_picker

### 2.4 Notification và offline

- flutter_local_notifications
- alarm
- timezone
- Isar (đã có dependency cho luồng local/offline)

### 2.5 UI/UX

- Material 3
- flex_color_scheme
- google_fonts
- flutter_animate
- lottie
- shimmer
- fl_chart

## 3) Các feature đang hoạt động

### 3.1 Auth

- Đăng nhập, đăng ký, quên mật khẩu, đổi mật khẩu.
- Hồ sơ người dùng: đổi thông tin, ảnh đại diện.
- Route guard theo trạng thái xác thực.

### 3.2 Dashboard

- Màn Home hiển thị các feature card chính.
- Điều hướng trực tiếp đến: Tasks, Notes ASR, Schedule OCR, Study Hub, Pomodoro.

### 3.3 Tasks (Nhắc lịch / Deadline)

- Tạo, sửa, xóa, toggle hoàn thành.
- Có priority và reminder_id để đặt local notification.
- Khi hoàn thành task: hủy notification tương ứng.
- Khi sửa task: tự chuyển về chưa hoàn thành và reschedule theo deadline mới.
- Rule deadline đã đồng nhất:
	- Create: không cho deadline trước thời điểm hiện tại.
	- Update: không cho deadline trước thời điểm hiện tại.

### 3.4 Notes ASR

- Tạo ghi chú bằng 2 cách:
	- Nói trực tiếp bằng microphone.
	- Upload file ghi âm (mp3, wav, m4a, aac, ogg, webm).
- Gửi dữ liệu sang Gemini để chuẩn hóa thành ghi chú bullet points.
- Subject name được AI suy luận, có thể fallback từ subject hint.
- Lưu Firestore với schema note thống nhất (không còn cờ ASR riêng).

### 3.5 Academic Schedule (OCR)

- Nhập tay buổi học hoặc import từ ảnh gallery/camera.
- Trích xuất text + parse thành các session.
- Kiểm tra conflict giờ học khi tạo/sửa/import.
- Hỗ trợ replace toàn bộ thời khóa biểu khi import.

### 3.6 Study modules

- Flashcards.
- Quizzes.
- Pomodoro.
- Các phần này đã có route riêng và tích hợp vào Study Hub/Home.

## 4) Quyền truy cập thiết bị

### 4.1 Android

- Camera: dùng cho OCR và ảnh hồ sơ.
- Microphone: dùng cho ASR.
- Có luồng fallback mở Settings khi thiếu quyền camera/micro ở các màn hình liên quan.

### 4.2 iOS

- Đã khai báo quyền micro và speech recognition cho ASR.
- Đã khai báo quyền camera/photo library cho OCR và chọn ảnh.

## 5) Luồng xử lý chính

### 5.1 Task reminder flow

1. User tạo task trong màn Tasks.
2. ViewModel gọi repository lưu Firestore.
3. Repository sinh reminder_id và schedule local notification nếu deadline > now.
4. Toggle completed => cancel reminder.
5. Edit task => re-activate task và reschedule theo deadline mới.

### 5.2 Notes ASR flow

1. User nói hoặc chọn file audio.
2. Notes ViewModel gọi Note AI Service.
3. Gemini trả JSON gồm subject_name và content.
4. App chuẩn hóa dữ liệu và lưu Firestore notes.
5. UI cập nhật theo stream notes.

### 5.3 Schedule OCR flow

1. User chọn ảnh từ gallery/camera.
2. Service OCR/AI trích xuất các phiên học.
3. ViewModel lọc conflict thời gian.
4. Repository ghi Firestore theo mode append hoặc replace.

## 6) Firestore schema thực tế (theo code hiện tại)

### users

- uid
- email
- display_name
- photo_url
- target_study_time
- các trường auth/profile liên quan khác

### tasks

- u_id
- title
- deadline (Timestamp)
- is_completed
- reminder_id
- priority (high/medium/low)
- created_at

### notes

- u_id
- subject_name
- content
- created_at
- updated_at

Ghi chú tương thích ngược:
- Reader note hiện vẫn đọc được subject_id cũ nếu còn dữ liệu legacy.

### schedules

- u_id
- subject_name
- day_of_week
- start_time (HH:mm)
- end_time (HH:mm)
- room
- is_from_ocr
- created_at

## 7) Cấu trúc dự án

```text
lib/
├── core/
│   ├── constants/
│   ├── providers/
│   ├── routing/
│   ├── services/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── tasks/
│   ├── notes/
│   ├── academic_schedule/
│   ├── flashcards/
│   ├── quizzes/
│   └── pomodoro/
└── main.dart
```

## 8) Điều hướng ứng dụng (routes)

- Public: /login, /register, /forgot-password
- Protected: /home, /study, /tasks, /notes-asr, /schedule, /profile, /change-password, /pomodoro, /flashcards, /quizzes, /quiz/:quizId

## 9) Quy tắc kỹ thuật đang áp dụng

- Mỗi feature tách rõ model/repository/viewmodel/view.
- Không nhồi logic nghiệp vụ vào UI widgets.
- Validate dữ liệu ở cả UI và ViewModel/Repository khi cần.
- Luồng async phải xử lý mounted context an toàn.
- Notification chỉ schedule cho deadline tương lai.

## 10) Cấu hình môi trường

### 10.1 Gemini

Ứng dụng cần truyền API key cho Gemini qua dart-define:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key
```

### 10.2 Firebase

- Dùng cấu hình trong lib/firebase_options.dart.
- Bảo đảm project Firebase đã bật Auth, Firestore, Storage, Functions theo nhu cầu module.

## 11) Chạy dự án

```bash
flutter pub get
flutter run
```

Test:

```bash
flutter test
```

Phân tích tĩnh:

```bash
flutter analyze
```

## 12) Ghi chú maintain

- Module notes_reminders cũ đã được tách thành 2 module độc lập: tasks và notes.
- Tài liệu này là nguồn tham chiếu kỹ thuật chính để review code, feature behavior và quyết định kiến trúc tiếp theo.
