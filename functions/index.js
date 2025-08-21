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

exports.onNewSale = functions.firestore
    .document("/transactions/{transactionId}")
    .onCreate(async (snapshot, context) => {
      const saleData = snapshot.data();
      const merchantId = saleData.merchantId;

      if (!merchantId) {
        console.log("Transaction has no merchantId.");
        return null;
      }

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
          title: "Nouvelle vente !",
          body: `Vous avez réalisé une vente de ${saleData.amount} FCFA pour le service ${saleData.serviceName}.`,
        },
        data: {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "balance_management",
          "transactionId": context.params.transactionId,
        },
      };

      console.log(`Sending sale notification to ${fcmTokens.length} tokens.`);

      // Send the notification
      try {
        const response = await admin.messaging().sendToDevice(fcmTokens, payload);
        console.log("Successfully sent sale notification:", response);
        return response;
      } catch (error) {
        console.error("Error sending sale notification:", error);
        return null;
      }
    });

exports.onNewMerchant = functions.firestore
    .document("/users/{userId}")
    .onCreate(async (snapshot, context) => {
      const newUser = snapshot.data();

      // Check if the new user is a merchant
      if (newUser.role !== "merchant") {
        return null;
      }

      // Get all admin users
      const adminUsersSnapshot = await admin.firestore()
          .collection("users").where("role", "==", "admin").get();

      if (adminUsersSnapshot.empty) {
        console.log("No admin users found to notify.");
        return null;
      }

      // Collect all FCM tokens from all admins
      const adminTokens = [];
      adminUsersSnapshot.forEach((doc) => {
        const adminData = doc.data();
        if (adminData.fcmTokens && Array.isArray(adminData.fcmTokens)) {
          adminTokens.push(...adminData.fcmTokens);
        }
      });

      if (adminTokens.length === 0) {
        console.log("No admin FCM tokens found.");
        return null;
      }

      // Construct the notification message
      const payload = {
        notification: {
          title: "Nouveau marchand à vérifier",
          body: `${newUser.name} vient de s'inscrire en tant que marchand.`,
        },
        data: {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "pending_verifications",
        },
      };

      console.log(`Sending notification to ${adminTokens.length} admin tokens.`);

      // Send the notification
      try {
        const response = await admin.messaging().sendToDevice(adminTokens, payload);
        console.log("Successfully sent message to admins:", response);
        return response;
      } catch (error) {
        console.error("Error sending message to admins:", error);
        return null;
      }
    });
