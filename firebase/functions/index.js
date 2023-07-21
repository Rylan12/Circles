const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();
const db = admin.firestore();

exports.sendMessage = onCall(async (request) => {
  const timestamp = Date.now();
  const username = request.data.username;

  if (username != "abbie" && username != "rylan") {
    throw new HttpsError("failed-precondition", "Invalid username");
  }

  const recipient = username == "abbie" ? "rylan" : "abbie";

  const senderRef = db.doc(`/users/${username}`);
  const recipientRef = db.doc(`/users/${recipient}`);

  return Promise.all([
    senderRef.get(),
    recipientRef.get()],
  ).then((snapshots) => {
    const senderSnapshot = snapshots[0];
    const recipientSnapshot = snapshots[1];

    const message = senderSnapshot.get("message");
    const recipientFCMToken = recipientSnapshot.get("token");

    const payload = {
      token: recipientFCMToken,
      notification: {
        body: message,
      },
    };

    return admin.messaging().send(payload).then((response) => {
      logger.info("Successfully sent message:", response);

      return db.doc(`/messages/${timestamp}`).set({
        message: message,
        timestamp: timestamp,
        senderUserName: username,
        senderRef: senderRef,
        recipientFCMToken: recipientFCMToken,
        recipientRef: recipientRef,
      }).then(() => {
        logger.info("New message added to database");
        return {success: true};
      }).catch((error) => {
        throw new HttpsError("unknown", error.message, error);
      });
    }).catch((error) => {
      throw new HttpsError("unknown", error.message, error);
    });
  }).catch((error) => {
    throw new HttpsError("unknown", error.message, error);
  });
});
