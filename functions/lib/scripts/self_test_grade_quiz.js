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
admin.initializeApp();
async function main() {
    const db = admin.firestore();
    // Lấy 1 quiz bất kỳ
    const quizSnap = await db.collection('quiz').limit(1).get();
    if (quizSnap.empty) {
        console.log('No quiz found');
        return;
    }
    const quizDoc = quizSnap.docs[0];
    const quizId = quizDoc.id;
    const ansDoc = await db.collection('quiz_answers').doc(quizId).get();
    if (!ansDoc.exists) {
        console.log(`quiz_answers/${quizId} not found`);
        return;
    }
    const answers = ansDoc.data()?.answers ?? {};
    const firstEntry = Object.entries(answers)[0];
    if (!firstEntry) {
        console.log(`quiz_answers/${quizId} has no answers`);
        return;
    }
    const [qId, correct] = firstEntry;
    console.log({ quizId, qId, correct });
}
main().catch((e) => {
    console.error(e);
    process.exitCode = 1;
});
//# sourceMappingURL=self_test_grade_quiz.js.map