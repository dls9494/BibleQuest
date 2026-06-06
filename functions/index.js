const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

// Initialize Gemini API
// Expects GEMINI_API_KEY to be set in functions config or environment
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

/**
 * Callable Function: Transliterate Latin input to target Indian script (e.g. "Yesu" -> "యేసు")
 */
exports.transliterateSearch = functions.https.onCall(async (data, context) => {
  const { text, targetLanguage } = data;
  if (!text || !targetLanguage) {
    throw new functions.https.HttpsError("invalid-argument", "Text and targetLanguage are required.");
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    // Fallback: return search term as is if API key is not configured
    return { transliteratedText: text };
  }

  try {
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    const prompt = `Transliterate the following text written in Latin script/English keyboard letters to its correct phonetical representation in the target script/language.
    Text: "${text}"
    Target Language/Locale: "${targetLanguage}" (e.g. te for Telugu, hi for Hindi, ta for Tamil, ml for Malayalam, kn for Kannada)
    Return ONLY the transliterated word or words. Do not write any explanations, translation, or extra text.`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const transliteratedText = response.text().trim();

    return { transliteratedText };
  } catch (error) {
    console.error("Transliteration error:", error);
    return { transliteratedText: text, error: error.message };
  }
});

/**
 * Callable Function: Generate quiz content using Gemini
 */
exports.generateQuizContent = functions.https.onCall(async (data, context) => {
  // Ensure host is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to generate quizzes.");
  }

  const { topic, bibleVersion, languageCode, questionCount = 5 } = data;
  if (!topic || !bibleVersion || !languageCode) {
    throw new functions.https.HttpsError("invalid-argument", "topic, bibleVersion, and languageCode are required.");
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new functions.https.HttpsError("failed-precondition", "Gemini API key is not configured on the server.");
  }

  try {
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    const prompt = `You are a Bible quiz generator. Generate a structured Bible quiz about: "${topic}".
    Use the Bible version: "${bibleVersion}".
    The primary language of the quiz must be: "${languageCode}" (use codes: en, te, hi, ta, ml, kn).
    Generate exactly ${questionCount} questions.
    
    Return the response ONLY as a valid JSON object matching the following structure. Do not wrap it in markdown code blocks like \`\`\`json.
    {
      "title": "Localized title of the quiz",
      "description": "Short localized description of the quiz",
      "topics": ["bible", "${topic.toLowerCase()}"],
      "questions": [
        {
          "order": 1,
          "type": "multiple_choice",
          "timeLimitSeconds": 20,
          "points": 1000,
          "questionText": "The question text in the primary language",
          "correctAnswerText": "",
          "verseReference": "Book Chapter:Verse (e.g. John 3:16)",
          "explanation": "Brief explanation of the answer",
          "options": [
            { "text": "Option 1 (incorrect)", "isCorrect": false },
            { "text": "Option 2 (incorrect)", "isCorrect": false },
            { "text": "Option 3 (correct)", "isCorrect": true },
            { "text": "Option 4 (incorrect)", "isCorrect": false }
          ]
        }
      ]
    }`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    let jsonText = response.text().trim();

    // Clean up potential markdown code fences if Gemini added them despite prompt
    if (jsonText.startsWith("```")) {
      jsonText = jsonText.replace(/^```json/, "").replace(/```$/, "").trim();
    }

    const quizData = JSON.parse(jsonText);

    // Save the generated quiz to Firestore under quizzes collection
    const db = admin.firestore();
    const quizRef = db.collection("quizzes").doc();
    const quizId = quizRef.id;

    // Create base quiz doc
    await quizRef.set({
      id: quizId,
      creator_id: context.auth.uid,
      title_key: `quiz_${quizId}_title`,
      bible_version: bibleVersion,
      topics: quizData.topics || [topic.toLowerCase()],
      is_public: true,
      question_count: quizData.questions.length,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });

    // Save Translation for Title/Description
    await quizRef.collection("translations").doc(languageCode).set({
      language: languageCode,
      title: quizData.title || topic,
      description: quizData.description || ""
    });

    // Save Questions and Options
    for (const q of quizData.questions) {
      const qRef = quizRef.collection("questions").doc();
      const questionId = qRef.id;

      await qRef.set({
        id: questionId,
        order: q.order,
        type: q.type || "multiple_choice",
        time_limit_seconds: q.timeLimitSeconds || 20,
        points: q.points || 1000,
        media_url: null,
        verse_reference: q.verseReference || "",
        explanation: q.explanation || ""
      });

      // Question Translation
      await qRef.collection("translations").doc(languageCode).set({
        question_text: q.questionText,
        correct_answer_text: q.correctAnswerText || ""
      });

      // Options
      if (q.options && Array.isArray(q.options)) {
        for (let i = 0; i < q.options.length; i++) {
          const opt = q.options[i];
          const optRef = qRef.collection("options").doc();
          const optionId = optRef.id;

          await optRef.set({
            id: optionId,
            order: i + 1,
            is_correct: opt.isCorrect
          });

          // Option Translation
          await optRef.collection("translations").doc(languageCode).set({
            text: opt.text
          });
        }
      }
    }

    return { success: true, quizId, title: quizData.title };
  } catch (error) {
    console.error("Quiz generation error:", error);
    throw new functions.https.HttpsError("internal", "Failed to generate quiz: " + error.message);
  }
});

/**
 * Callable Function: Calculate scores after a question ends in a live game session.
 * Computes scores based on correct answers and response speed (faster submits get higher score).
 */
exports.processSessionQuestionResult = functions.https.onCall(async (data, context) => {
  const { sessionId } = data;
  if (!sessionId) {
    throw new functions.https.HttpsError("invalid-argument", "sessionId is required.");
  }

  const db = admin.firestore();
  const sessionRef = db.collection("game_sessions").doc(sessionId);

  try {
    await db.runTransaction(async (transaction) => {
      const sessionDoc = await transaction.get(sessionRef);
      if (!sessionDoc.exists) {
        throw new Error("Session does not exist.");
      }

      const session = sessionDoc.data();
      if (session.status !== "in_progress") {
        throw new Error("Session is not in progress.");
      }

      const currentQuestionIndex = session.current_question_index;
      const currentQuestion = session.current_question;
      const startTime = session.question_start_time.toDate().getTime();

      // Fetch all players
      const playersQueryRef = sessionRef.collection("players");
      const playersSnapshot = await transaction.get(playersQueryRef);

      const distribution = {}; // Map of Option ID -> Count
      const correctOptionId = currentQuestion.correct_option_id;
      const timeLimitMs = (currentQuestion.time_limit_seconds || 20) * 1000;

      const playerUpdates = [];

      for (const playerDoc of playersSnapshot.docs) {
        const player = playerDoc.data();
        const playerId = playerDoc.id;

        // Fetch player answers
        const answersRef = playersQueryRef.doc(playerId).collection("answers");
        const answersSnapshot = await transaction.get(answersRef);
        
        let selectedOptionId = null;
        let answeredAt = null;

        // Find answer for current question
        for (const answerDoc of answersSnapshot.docs) {
          const ans = answerDoc.data();
          if (ans.question_id === currentQuestion.id) {
            selectedOptionId = ans.selected_option_id;
            answeredAt = ans.answered_at ? ans.answered_at.toDate().getTime() : null;
            break;
          }
        }

        let isCorrect = false;
        let pointsEarned = 0;

        if (selectedOptionId) {
          // Increment option count for distribution
          distribution[selectedOptionId] = (distribution[selectedOptionId] || 0) + 1;

          // Check correctness
          isCorrect = selectedOptionId === correctOptionId;
          
          if (isCorrect) {
            const timeTaken = answeredAt ? Math.max(0, answeredAt - startTime) : timeLimitMs;
            // Kahoot score formula: points = base_points * (1 - ((time_taken / time_limit) / 2))
            // E.g., instant answer gets 1000 points, answer at final second gets 500 points.
            const basePoints = currentQuestion.points || 1000;
            const ratio = Math.min(1.0, timeTaken / timeLimitMs);
            pointsEarned = Math.round(basePoints * (1.0 - (ratio / 2.0)));
          }
        } else {
          // Player didn't answer
          distribution["no_answer"] = (distribution["no_answer"] || 0) + 1;
        }

        const newScore = (player.score || 0) + pointsEarned;
        playerUpdates.push({
          ref: playersQueryRef.doc(playerId),
          score: newScore,
          isCorrect,
          pointsEarned
        });
      }

      // Write updated player scores inside transaction
      for (const update of playerUpdates) {
        transaction.update(update.ref, { score: update.score });
      }

      // Fetch updated player list to build leaderboard
      // For transaction consistency, we compute from updated local variables
      const sortedPlayers = playerUpdates
        .map(u => ({
          name: playersSnapshot.docs.find(d => d.id === u.ref.id).data().name,
          score: u.score,
          pointsEarned: u.pointsEarned
        }))
        .sort((a, b) => b.score - a.score)
        .slice(0, 5); // Top 5 leaderboard

      // Write question result back to the session
      transaction.update(sessionRef, {
        question_result: {
          correct_option_id: correctOptionId || "",
          distribution: distribution,
          leaderboard: sortedPlayers
        }
      });
    });

    return { success: true };
  } catch (error) {
    console.error("Score processing transaction error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
