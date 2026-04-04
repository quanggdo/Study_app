import * as admin from 'firebase-admin';

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

  const answers = (ansDoc.data() as any)?.answers ?? {};
  const firstEntry = Object.entries(answers)[0] as [string, any] | undefined;
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

