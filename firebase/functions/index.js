/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {getDatabase} = require("firebase-admin/database");
const logger = require("firebase-functions/logger");

exports.sendMessage = onCall((request) => {
  const username = request.data.username;

  if (username != "abbie" && username != "rylan") {
    throw new HttpsError("failed-precondition", "Invalid username");
  }

  return getDatabase().ref("/messages").push({
    text: request.data.text,
    timestamp: Date.now(),
    author: username,
    target: username == "abbie" ? "rylan" : "abbie",
  }).then(() => {
    logger.info("New message written");
    return;
  }).catch((error) => {
    throw new HttpsError("unknown", error.message, error);
  });
});
