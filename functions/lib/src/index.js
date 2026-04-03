"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.gradeQuiz = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
admin.initializeApp();
exports.gradeQuiz = (0, https_1.onCall)(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError('unauthenticated', 'Bạn cần đăng nhập để làm quiz.');
    }
    const data = request.data;
    const quizId = (data.quiz_id ?? '').toString().trim();
    if (!quizId) {
        throw new https_1.HttpsError('invalid-argument', 'Thiếu quiz_id');
    }
    const userAnswers = Array.isArray(data.user_answers) ? data.user_answers : [];
    // Debug: request shape
    console.log('[gradeQuiz] quizId=', quizId, 'uid=', uid);
    console.log('[gradeQuiz] user_answers sample=', userAnswers.slice(0, 3));
    // 1) Load quiz
    const quizRef = admin.firestore().collection('quiz').doc(quizId);
    const quizSnap = await quizRef.get();
    if (!quizSnap.exists) {
        throw new https_1.HttpsError('not-found', 'Không tìm thấy quiz');
    }
    const quiz = quizSnap.data();
    const questions = Array.isArray(quiz.questions) ? quiz.questions : [];
    const qIdList = questions
        .map((q) => (q?.q_id ?? q?.qId ?? '').toString().trim())
        .filter((s) => s.length > 0);
    const qIds = new Set(qIdList);
    console.log('[gradeQuiz] quiz qIds sample=', qIdList.slice(0, 5));
    const normalizedUserAnswers = userAnswers
        .map((a) => ({
        q_id: (a?.q_id ?? a?.qId ?? '').toString().trim(),
        // app gửi `user_choice`, nhưng phòng trường hợp app/model khác thì nhận thêm userChoice
        user_choice: (a?.user_choice ?? a?.userChoice ?? '').toString().trim(),
    }))
        .filter((a) => a.q_id.length > 0);
    // 2) Load correct answers
    // Ưu tiên: quiz_answers/{quizId}.answers (private)
    // Fallback: quiz/{quizId}.correct_answers (public, theo data mẫu hiện có)
    let answersMap = {};
    const ansRef = admin.firestore().collection('quiz_answers').doc(quizId);
    const ansSnap = await ansRef.get();
    if (ansSnap.exists) {
        const ansData = ansSnap.data();
        const answersContainer = ansData?.answers ?? ansData?.correct_answers ?? {};
        const answersMapRaw = answersContainer;
        for (const [k, v] of Object.entries(answersMapRaw)) {
            answersMap[k.toString().trim()] = (v ?? '').toString().trim();
        }
    }
    if (Object.keys(answersMap).length === 0) {
        // Fallback: parse correct_answers array trong quiz doc
        const correctAnswers = Array.isArray(quiz.correct_answers)
            ? quiz.correct_answers
            : [];
        for (const item of correctAnswers) {
            const qId = (item?.q_id ?? item?.qId ?? '').toString().trim();
            const opt = (item?.correct_opt_id ?? item?.correctOptId ?? '')
                .toString()
                .trim();
            if (qId && opt) {
                answersMap[qId] = opt;
            }
        }
    }
    if (Object.keys(answersMap).length === 0) {
        throw new https_1.HttpsError('failed-precondition', 'Chưa có đáp án cho quiz này. Cần `quiz_answers/{quizId}.answers` hoặc `quiz.correct_answers`.');
    }
    console.log('[gradeQuiz] answersMap size=', Object.keys(answersMap).length);
    console.log('[gradeQuiz] answersMap sample=', Object.entries(answersMap).slice(0, 5));
    // 3) Grade
    const total = qIdList.length;
    let score = 0;
    const byQId = new Map();
    for (const a of normalizedUserAnswers) {
        if (!qIds.has(a.q_id))
            continue;
        byQId.set(a.q_id, a.user_choice);
    }
    console.log('[gradeQuiz] matched user answers=', byQId.size);
    const review = [];
    const wrong_questions = [];
    for (const qId of qIdList) {
        const user_choice = (byQId.get(qId) ?? '').toString().trim();
        const correct_choice = (answersMap[qId] ?? '').toString().trim();
        const is_correct = user_choice.length > 0 &&
            correct_choice.length > 0 &&
            user_choice.toLowerCase() === correct_choice.toLowerCase();
        if (is_correct) {
            score += 1;
        }
        else {
            wrong_questions.push({ q_id: qId, user_choice });
        }
        review.push({ q_id: qId, user_choice, correct_choice, is_correct });
    }
    // 4) Save progress (server-side)
    const progress = {
        u_id: uid,
        quiz_id: quizId,
        score,
        total,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        wrong_questions,
        attempt_id: (data.attempt_id ?? '').toString(),
    };
    await admin.firestore().collection('user_progress').add(progress);
    // Return result to client - keep key names consistent with app models
    return {
        score,
        total,
        wrong_questions,
        review,
        completedAt: new Date().toISOString(),
    };
});
//# sourceMappingURL=index.js.map