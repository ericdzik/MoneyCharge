const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onNewReview = functions.firestore
    .document("/users/{merchantId}/reviews/{reviewId}")
    .onCreate(async (snapshot, context) => {
      const merchantId = context.params.merchantId;
      const reviewData = snapshot.data();

      // Get the merchant's user document
      const merchantRef = admin.firestore().collection("users").doc(merchantId);
      const merchantDoc = await merchantRef.get();

      if (!merchantDoc.exists) {
        console.log(`Merchant ${merchantId} not found.`);
        return null;
      }

      const merchantData = merchantDoc.data();
      const fcmTokens = merchantData.fcmTokens;

      if (!fcmTokens || !Array.isArray(fcmTokens) || fcmTokens.length === 0) {
        console.log(`Merchant ${merchantId} has no FCM tokens.`);
        return null;
      }

      // Construct the notification message
      const payload = {
        notification: {
          title: "Vous avez reçu un nouvel avis !",
          body: `Un client vous a laissé une note de ${reviewData.rating}/5.`,
        },
        data: {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "reviews",
          "merchantId": merchantId,
        },
      };

      console.log(`Sending notification to ${fcmTokens.length} tokens.`);

      // Send the notification
      try {
        const response = await admin.messaging().sendToDevice(fcmTokens, payload);
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.error(
                "Failure sending notification to",
                fcmTokens[index],
                error,
            );
            // Cleanup the tokens who are not registered anymore.
            if (error.code === "messaging/invalid-registration-token" ||
                error.code === "messaging/registration-token-not-registered") {
              tokensToRemove.push(fcmTokens[index]);
            }
          }
        });

        // Remove the invalid tokens from the user's document
        if (tokensToRemove.length > 0) {
          console.log(`Removing invalid tokens: ${tokensToRemove}`);
          await merchantRef.update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
          });
        }

        return response;
      } catch (error) {
        console.error("Error sending message:", error);
        return null;
      }
    });
