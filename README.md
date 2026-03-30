# Student Academic Assistant (SAA) 🎓

**Student Academic Assistant** là một ứng dụng hỗ trợ học tập toàn diện được thiết kế để giúp sinh viên quản lý thời gian, ghi chú thông minh và tối ưu hóa hiệu suất học tập thông qua công nghệ AI (OCR, ASR) và các phương pháp khoa học (Pomodoro, Flashcards).

---

## I. Kế hoạch triển khai (Project Roadmap) 🚀

Dự án được chia thành 5 giai đoạn chiến lược với sự phân công cụ thể cho từng thành viên:

| Giai đoạn | Tính năng trọng tâm | Nhân sự phụ trách | Trạng thái |
| :--- | :--- | :--- | :--- |
| **Giai đoạn 1** | Auth & Core Infrastructure (Firebase, Routing, Theme) | **Leader / Dev A** | 🔄 In Progress |
| **Giai đoạn 2** | Ôn tập (Quiz/Flashcard) & Pomodoro Timer | **Dev B** | ⏳ Todo |
| **Giai đoạn 3** | Academic Management (Schedule/OCR) | **Dev A + Dev C** | ⏳ Todo |
| **Giai đoạn 4** | Ghi chú & Nhắc nhở (Notes/ASR/Local Notify) | **Dev B + Dev C** | ⏳ Todo |
| **Giai đoạn 5** | Data Visualization (Biểu đồ) & Polish UI | **Cả nhóm** | ⏳ Todo |

---

## II. Kiến trúc & Luồng dữ liệu (System Architecture) 🛠️

Hệ thống hoạt động theo mô hình: **Input** ➡️ **Processing** ➡️ **Storage** ➡️ **Output**.

### 1. Luồng Trắc nghiệm & Flashcard (Quiz Management)
- **Input:** Người dùng làm bài Quiz hoặc lật Flashcard.
- **Processing:** 
  - Repository gọi `quiz` collection -> Lấy đề bài (chỉ gồm câu hỏi và các lựa chọn, **không có đáp án đúng**).
  - Khi hoàn thành: Gửi mảng `user_answers[]` (chứa `q_id` và `user_choice`) lên **Cloud Function**.
  - **Cloud Function**: Tính điểm, cập nhật `user_progress` lưu kèm mảng `wrong_questions[]` (Object `{q_id, user_choice}`).
- **Output:** Trả về kết quả so khớp "Câu bạn chọn" vs "Đáp án đúng" (lấy từ `quiz_answers`).

### 2. Luồng OCR (Thời khóa biểu)
- **Input:** Flutter chụp ảnh từ Camera/Gallery.
- **Processing:** Gửi ảnh qua `google_ml_kit` -> Nhận Text thô -> Logic Regex/AI xử lý -> Tạo các Object `schedules`. 
  - **Quy chuẩn dữ liệu**: `time_slot` được tách thành `start_time` và `end_time` (dạng số/timestamp) để tính toán thời gian đến tiết tiếp theo.
- **Storage:** Firestore `schedules` (Gán nhãn `is_from_ocr: true`).
- **Output:** Hiển thị TKB dạng bảng trực quan.

### 3. Luồng ASR & Alarm (Ghi chú & Nhắc nhở)
- **Input:** Giọng nói người dùng thông qua `speech_to_text`.
- **Processing:** 
  - Chuyển giọng nói thành văn bản chuẩn (`content`).
  - Nếu AI nhận diện có ngày/giờ: Tạo Object `tasks`.
- **Storage:** 
  - Lưu vào Firestore `notes` (Gán nhãn `is_from_asr: true`).
  - Lưu vào Firestore `tasks` VÀ gọi `flutter_local_notifications` để đặt lịch báo thức/nhắc nhở ngay trên thiết bị (chạy offline).

### 4. Luồng Pomodoro & Deep Work Mode
- **Input:** Người dùng chọn Task và bắt đầu Timer Pomodoro.
- **Deep Work Mode:** Khi Timer chạy, App kích hoạt chế độ "Tập trung sâu":
  - Tạm dừng (Mute) toàn bộ thông báo từ chính App (trừ báo thức hết giờ).
  - (Tùy chọn Android) Tích hợp `device_policy_manager` để hạn chế mở các ứng dụng gây xao nhãng khác.
- **Storage:** Lưu vào `focus_sessions` ngay sau khi phiên kết thúc.

### 5. Luồng Visualization (Hệ thống Biểu đồ)
- **Input:** Truy vấn dữ liệu từ `user_progress` (điểm số) và `focus_sessions` (thời gian tập trung).
- **Processing:** Tính toán trung bình và tổng hợp dữ liệu theo ngày/tuần.
- **Output:** Truyền dữ liệu vào `fl_chart` để vẽ biểu đồ Line Chart (tiến độ) và Bar Chart (năng suất).

---

## III. Thiết kế cơ sở dữ liệu (Firestore Schema) 📊

| Collection | Document ID | Các trường chính (Fields) | Ghi chú |
| :--- | :--- | :--- | :--- |
| `quiz` | Auto-ID | `title, category, author, timeLimit, questions[], createdAt` | Chứa đề bài, tuyệt đối **không chứa đáp án đúng** (Security). |
| `quiz_answers` | `quiz_id` | `correct_answers[]` | Collection riêng tư, chỉ Cloud Function được phép truy cập để chấm điểm. |
| `flashcards` | Auto-ID | `title, category, author, description, cards[], createdAt` | `cards[]` chứa object `{id, front, back}`. |
| `users` | `uid` (Auth) | `email, display_name, photo_url, target_study_time, device_token` | `device_token` dùng để gửi Push Notification. |
| `schedules` | Auto-ID | `u_id, subject_name, day_of_week, start_time, end_time, room, is_from_ocr` | `start/end_time` dùng để tính Dashboard UI. |
| `tasks` | Auto-ID | `u_id, title, deadline (Timestamp), is_completed, priority, reminder_id` | `reminder_id` dùng định danh Local Notification. |
| `notes` | Auto-ID | `u_id, subject_id, content, audio_url, is_from_asr` | `content` chứa text đã convert từ ASR. |
| `user_progress` | Auto-ID | `u_id, quiz_id, score, total, completedAt, wrong_questions[]` | `wrong_questions[]` lưu Object `{q_id, user_choice}`. |
| `focus_sessions` | Auto-ID | `u_id, duration_minutes, session_date, task_id, mode` | **Note**: Nếu Task bị xóa, set `task_id = null` để giữ data biểu đồ. |

### Security Rules (Nguyên tắc phân quyền)
- **User Data**: `allow read, write: if request.auth.uid == resource.data.u_id` (Chỉ chủ sở hữu mới xem được TKB/Ghi chú của mình).
- **Public Quiz**: `allow read: if request.auth != null` (Mọi sinh viên đăng nhập đều xem được đề).
- **Private Answers**: `allow read, write: if false` (Khóa hoàn toàn trên Firestore, chỉ Cloud Functions dùng quyền Admin để đọc).

---

## IV. Phân chia kỹ thuật (Tech Stack) 💻

- **State Management:** `Provider` hoặc `Riverpod` (Ưu tiên Riverpod để tối ưu dependency injection).
- **AI Services:** 
  - `google_ml_kit` (OCR - Xử lý phía client, nhẹ).
  - `speech_to_text` (ASR - Nhận diện giọng nói).
- **Storage:**
  - `Cloud Firestore`: Đồng bộ dữ liệu real-time.
  - `Firebase Storage`: Lưu trữ tệp tin (Ảnh chụp TKB, ảnh profile, file âm thanh).
  - `Isar` / `Shared Preferences`: Lưu trữ dữ liệu Offline & cấu hình.

### Chiến lược Offline-First 
- **Luồng đồng bộ**: Khi App mở, ưu tiên lấy dữ liệu từ **Isar (Local)** để hiển thị UI ngay lập tức nhằm tránh giật lag. Sau đó mới gọi Stream từ Firestore để cập nhật bản mới nhất và ghi đè vào Isar.
- **Xử lý ghi chú (Notes)**: Cho phép tạo Note khi offline, lưu vào Isar với cờ `is_synced: false`. Khi có mạng, một `Background Service` sẽ tự động đẩy dữ liệu lên Firestore.
- **Notification:** `flutter_local_notifications` + `android_alarm_manager_plus`.
- **UI Libraries:** `fl_chart` cho báo cáo, `google_fonts` cho typography.

---

## V. Hướng dẫn dành cho thành viên (Team Collaboration) 🤝

Để làm việc hiệu quả và tránh xung đột code, các thành viên cần tuân thủ:

### 1. Quy tắc Git (Git Flow)
- **Main Branch:** Chỉ chứa code đã stable.
- **Feature Branches:** Tạo nhánh mới từ `main` cho mỗi tính năng. 
  - Cấu trúc: `feature/ten-tinh-nang` (VD: `feature/auth`, `feature/ocr`).
- **Pull Request (PR):** Phải được ít nhất 1 thành viên khác review trước khi merge vào `main`.

### 2. Cấu trúc thư mục (Folder Structure)
Dự án tuân theo mô hình **MVVM (Feature-first)**:
```text
lib/
├── core/             # Repository chung, Services, Themes
│   ├── utils/        # validators.dart, date_formatter.dart
│   ├── network/      # api_client.dart (Dự phòng cho API ngoài)
│   ├── providers/    # Global providers
│   └── services/     # Firebase, Storage, Notify services
├── features/        
│   ├── auth/         # UI, Logic, Model cho từng tính năng
│   ├── schedule/
│   ├── notes/
├── main.dart
```

### 3. Commit Message Standards
Sử dụng format: `[Type]: Short description`
- `feat`: Tính năng mới
- `fix`: Sửa lỗi
- `docs`: Cập nhật README/Tài liệu
- `style`: Định dạng code (whitespace, formatting)

---

## VI. Hướng dẫn kỹ thuật chi tiết (Technical Implementation Guide) 🛠️

### 1. Kiến trúc MVVM + Riverpod
Mỗi feature (module) phải tuân thủ cấu trúc 4 lớp để đảm bảo tính dễ bảo trì:

- **Model**: Định nghĩa dữ liệu (sử dụng `freezed` & `json_serializable`).
- **View**: Chỉ chứa UI Flutter Widgets. Không đặt logic tính toán ở đây.
- **ViewModel (StateNotifier/Notifier)**: 
  - Quản lý trạng thái (State) của màn hình.
  - Gọi các phương thức từ Repository.
  - Sử dụng `riverpod` để cung cấp state cho View.
- **Repository**: Lớp trừu tượng để lấy dữ liệu (từ Firestore, Local DB hoặc AI Service).

**Luồng dữ liệu:** `View` ➡️ `ViewModel` ➡️ `Repository` ➡️ `Data Source`.

### 2. Tích hợp AI Toolkit & Cloud Functions

#### A. AI Services (Client-side)
- **OCR (Schedule Scan)**: Sử dụng gói `google_mlkit_text_recognition`. Xử lý ảnh trực tiếp trên thiết bị để tối ưu tốc độ và chi phí.
- **ASR (Voice Notes)**: Sử dụng `speech_to_text`. Kết quả trả về dạng stream text để hiển thị real-time cho người dùng khi đang nói.

#### B. Generative AI (Gemini / AI Toolkit)
> [!CAUTION]
> **BẢO MẬT API KEY**: Tuyệt đối **KHÔNG** push API Key lên GitHub. Sử dụng file `.env` hoặc lưu trữ trong một lớp riêng (`secrets.dart`) đã được thêm vào `.gitignore`.

- **Summarization**: Sau khi OCR hoặc ASR có text thô, gửi dữ liệu lên Gemini (thông qua `google_generative_ai`) để:
  - Tóm tắt nội dung bài giảng.
  - Tự động tạo câu hỏi Quiz từ nội dung ghi chú. Đảm bảo format JSON để app parse được.
  - Gợi ý lộ trình học tập dựa trên Thời khóa biểu.

#### C. Quy trình xử lý "Low-Resource" (Tối ưu thiết bị RAM yếu)
Để máy  không bị "đơ" khi xử lý AI:
- **OCR**: Thay vì quét toàn bộ ảnh độ phân giải cao, hãy thiết kế UI (Crop Tool) để người dùng chỉ cắt lấy phần bảng TKB. Việc này làm giảm dung lượng bộ nhớ khi xử lý Text Recognition.
- **ASR**: Sử dụng cơ chế **Debounce** (đợi người dùng ngừng nói 500ms mới bắt đầu parse Text sang Task) để tránh CPU phải tính toán liên tục.

### 3. Cấu trúc Module tiêu biểu (Ví dụ: Feature Notes)
```text
lib/features/notes/
├── models/             # note_model.dart (Dữ liệu ghi chú)
├── repositories/       # notes_repository.dart (Firebase + Isar logic)
├── viewmodels/         # notes_viewmodel.dart (Quản lý List<Note> và UI State)
├── views/              # widgets/ (Các thành phần nhỏ), notes_screen.dart (UI chính)
└── services/           # (Optional) asr_service.dart (Wrapper cho module)
```

### 4. Dịch vụ bổ trợ cho từng Module
- **Auth**: Firebase Auth + Google Sign-In.
- **Storage**: Firebase Storage (Lưu trữ media: `/users/`, `/notes/`, `/schedules/`).
- **Schedule**: ML Kit (OCR) + Cloud Firestore.
- **Revision**: Isar (Lưu trữ flashcard offline) + `fl_chart`.
- **Pomodoro**: `alarm` (Báo thức) + Logic **Deep Work Mode** (Tắt thông báo in-app).
- **Reminder**: `flutter_local_notifications` (Thông báo offline).

---

## VII. Giao diện & Trải nghiệm người dùng (UI/UX Guidelines) ✨

Để đảm bảo ứng dụng có giao diện nhất quán, hiện đại và cao cấp (Premium look), tất cả thành viên khi tham gia code **phải** tuân thủ các quy tắc thiết kế sau:

### 1. Hệ màu & Chủ đề (Theming)
Dự án sử dụng gói `flex_color_scheme` (Indigo scheme):
- **Màu sắc chủ đạo**: Indigo (Màu chàm) – Tạo cảm giác chuyên nghiệp, học thuật.
- **Support**: Ứng dụng hỗ trợ cả **Giao diện Sáng (Light)** và **Giao diện Tối (Dark)** – Hãy sử dụng các biến màu từ `Theme.of(context).colorScheme`.

### 2. Typography & Icons
- **Font chữ**: Sử dụng phông `Inter` (Google Fonts). Tuyệt đối không hard-code font size lạ, ưu tiên dùng `textTheme.bodyLarge`, `titleMedium`... từ Theme.
- **Biểu tượng**: Ưu tiên sử dụng `Icons.material_rounded` và `CupertinoIcons` để nét vẽ mượt mà, phù hợp với phong cách bo góc của Material 3.

### 3. Thành phần UI chuẩn
- **Bo góc (Corner Radius)**: Tất cả `Card`, `Button`, `Dialog` chuẩn hóa bo góc **16.0**.
- **Khoảng cách (Spacing)**: Sử dụng bội số của 8 (8px, 16px, 24px). Lề chuẩn của màn hình là **16.0**.
- **Hiệu ứng (Motion)**: Sử dụng gói `flutter_animate` cho các hiệu ứng xuất hiện (Fade, Slide) để tăng trải nghiệm người dùng.

### 4. Trạng thái Loading & Empty
- **Shimmer**: Sử dụng `Shimmer` cho trạng thái tải danh sách dữ liệu để tránh tình trạng màn hình trống trơn hoặc chỉ có icon xoay vòng.

---
*Chúc nhóm hoàn thành xuất sắc dự án!* 🚀
