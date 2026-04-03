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
const admin = __importStar(require("firebase-admin"));
/**
 * Migrate correct answers from `quiz/{quizId}.correct_answers[]`
 * to private `quiz_answers/{quizId}.answers` (map {q_id: correct_opt_id}).
 *
 * Run:
 *   cd functions
 *   npm run migrate:quiz-answers
 */
admin.initializeApp();
async function main() {
    const db = admin.firestore();
    const quizSnap = await db.collection('quiz').get();
    console.log(`[migrate] Found ${quizSnap.size} quiz docs`);
    let migrated = 0;
    let skippedNoCorrect = 0;
    let skippedAlreadyHas = 0;
    let skippedInvalid = 0;
    for (const doc of quizSnap.docs) {
        const quizId = doc.id;
        const quizData = doc.data();
        const correctAnswers = quizData.correct_answers;
        if (!Array.isArray(correctAnswers) || correctAnswers.length == 0) {
            skippedNoCorrect++;
            continue;
        }
        const answers = {};
        for (const item of correctAnswers) {
            const qId = (item?.q_id ?? '').toString().trim();
            const correct = (item?.correct_opt_id ?? '').toString().trim();
            if (!qId || !correct) {
                skippedInvalid++;
                continue;
            }
            answers[qId] = correct;
        }
        if (Object.keys(answers).length === 0) {
            skippedInvalid++;
            continue;
        }
        const ansRef = db.collection('quiz_answers').doc(quizId);
        const ansSnap = await ansRef.get();
        if (ansSnap.exists && ansSnap.data()?.answers) {
            skippedAlreadyHas++;
            continue;
        }
        await ansRef.set({
            answers,
            migratedAt: admin.firestore.FieldValue.serverTimestamp(),
            source: 'quiz.correct_answers',
        }, { merge: true });
        migrated++;
        console.log(`[migrate] quiz=${quizId}: wrote ${Object.keys(answers).length} answers`);
    }
    console.log('[migrate] Done');
    console.log({ migrated, skippedNoCorrect, skippedAlreadyHas, skippedInvalid });
}
main().catch((e) => {
    console.error(e);
    process.exitCode = 1;
});
//# sourceMappingURL=migrate_quiz_answers.js.map