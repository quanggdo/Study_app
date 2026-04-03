import * as admin from 'firebase-admin';

/**
 * Migrate correct answers from `quiz/{quizId}.correct_answers[]`
 * to private `quiz_answers/{quizId}.answers` (map {q_id: correct_opt_id}).
 *
 * Run:
 *   cd functions
 *   npm run migrate:quiz-answers
 */

admin.initializeApp();

type CorrectAnswerItem = {
  q_id?: unknown;
  correct_opt_id?: unknown;
};

type QuizDoc = {
  correct_answers?: unknown;
};

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
    const quizData = doc.data() as QuizDoc;

    const correctAnswers = quizData.correct_answers;
    if (!Array.isArray(correctAnswers) || correctAnswers.length == 0) {
      skippedNoCorrect++;
      continue;
    }

    const answers: Record<string, string> = {};
    for (const item of correctAnswers as CorrectAnswerItem[]) {
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
    if (ansSnap.exists && (ansSnap.data() as any)?.answers) {
      skippedAlreadyHas++;
      continue;
    }

    await ansRef.set(
      {
        answers,
        migratedAt: admin.firestore.FieldValue.serverTimestamp(),
        source: 'quiz.correct_answers',
      },
      { merge: true },
    );

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

