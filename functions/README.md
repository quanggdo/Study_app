# SAA Cloud Functions

Thư mục này chứa **Firebase Cloud Functions (TypeScript)** cho project.

## Functions

- `gradeQuiz` (callable)
  - Input:
    ```json
    {
      "quiz_id": "<quizId>",
      "user_answers": [{"q_id": "p1", "user_choice": "b"}],
      "attempt_id": "<optional uuid>"
    }
    ```
  - Reads:
    - `quiz/{quizId}` (đề)
    - `quiz_answers/{quizId}` (đáp án đúng, private)
  - Writes:
    - `user_progress` (server-side)

## Migrate đáp án (từ `quiz.correct_answers[]` -> `quiz_answers/{quizId}`)

> README của app yêu cầu **không để đáp án đúng trong doc `quiz`** (vì client có quyền read `quiz`).

Chạy migrate 1 lần:

```powershell
cd functions
npm install
npm run migrate:quiz-answers
```

Script sẽ:
- đọc toàn bộ `quiz/*`
- lấy `correct_answers[]`
- ghi sang `quiz_answers/{quizId}.answers` dạng map `{ q_id: correct_opt_id }`

## Local dev

```powershell
cd functions
npm install
npm run build
```

## Deploy

```powershell
cd functions
npm install
npm run deploy
```

> Deploy/serve cần Firebase CLI đã đăng nhập và chọn đúng project.
