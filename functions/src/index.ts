import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Complete a module and award points (server-side validation)
 * This prevents client-side manipulation of points
 */
export const completeModule = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to complete modules."
    );
  }

  const userId = context.auth.uid;
  const {courseId, moduleId} = data;

  // Validate required parameters
  if (!courseId || !moduleId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "courseId and moduleId are required."
    );
  }

  try {
    const db = admin.firestore();
    const progressId = `${userId}_${moduleId}`;

    // Check if already completed
    const existingDoc = await db.collection("userProgress").doc(progressId).get();

    if (existingDoc.exists) {
      const existingData = existingDoc.data();
      if (existingData?.isCompleted) {
        throw new functions.https.HttpsError(
          "already-exists",
          "Module already completed."
        );
      }
    }

    // Fetch module data to get actual point value (server-side)
    const moduleDoc = await db.collection("modules").doc(moduleId).get();

    if (!moduleDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Module not found."
      );
    }

    const moduleData = moduleDoc.data();
    const pointsReward = moduleData?.pointsReward || 0;

    // Create progress record
    const progress = {
      id: progressId,
      userId: userId,
      courseId: courseId,
      moduleId: moduleId,
      isCompleted: true,
      pointsEarned: pointsReward,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Use batch write for atomicity
    const batch = db.batch();

    // Update user progress
    batch.set(db.collection("userProgress").doc(progressId), progress);

    // Update user's total points (server controls the value)
    batch.update(db.collection("users").doc(userId), {
      points: admin.firestore.FieldValue.increment(pointsReward),
    });

    await batch.commit();

    return {
      success: true,
      pointsEarned: pointsReward,
      message: `Module completed! You earned ${pointsReward} points.`,
    };
  } catch (error) {
    console.error("Error completing module:", error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      "internal",
      "Failed to complete module."
    );
  }
});

/**
 * Complete an activity and award points (server-side validation)
 */
export const completeActivity = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to complete activities."
    );
  }

  const userId = context.auth.uid;
  const {courseId, moduleId, activityId, answer} = data;

  // Validate required parameters
  if (!courseId || !moduleId || !activityId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "courseId, moduleId, and activityId are required."
    );
  }

  try {
    const db = admin.firestore();
    const progressId = `${userId}_${activityId}`;

    // Check if already completed
    const existingDoc = await db.collection("userProgress").doc(progressId).get();

    if (existingDoc.exists) {
      const existingData = existingDoc.data();
      if (existingData?.isCompleted) {
        throw new functions.https.HttpsError(
          "already-exists",
          "Activity already completed."
        );
      }
    }

    // Fetch module to get activity data
    const moduleDoc = await db.collection("modules").doc(moduleId).get();

    if (!moduleDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Module not found."
      );
    }

    const moduleData = moduleDoc.data();
    const activities = moduleData?.activities || [];
    const activity = activities.find((a: any) => a.id === activityId);

    if (!activity) {
      throw new functions.https.HttpsError(
        "not-found",
        "Activity not found."
      );
    }

    const pointsReward = activity.pointsReward || 0;

    // TODO: Add answer validation here if needed
    // For now, we trust that the user completed the activity
    // In a production system, you would validate the answer against correct answers

    // Create progress record
    const progress = {
      id: progressId,
      userId: userId,
      courseId: courseId,
      moduleId: moduleId,
      activityId: activityId,
      isCompleted: true,
      pointsEarned: pointsReward,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Use batch write for atomicity
    const batch = db.batch();

    // Update user progress
    batch.set(db.collection("userProgress").doc(progressId), progress);

    // Update user's total points (server controls the value)
    batch.update(db.collection("users").doc(userId), {
      points: admin.firestore.FieldValue.increment(pointsReward),
    });

    await batch.commit();

    return {
      success: true,
      pointsEarned: pointsReward,
      message: `Activity completed! You earned ${pointsReward} points.`,
    };
  } catch (error) {
    console.error("Error completing activity:", error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      "internal",
      "Failed to complete activity."
    );
  }
});
