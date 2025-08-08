const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Se déclenche à chaque écriture (création, mise à jour, suppression)
 * sur un document de la collection 'reviews'.
 * Met à jour la note moyenne et le nombre d'avis pour le marchand concerné.
 */
exports.updateMerchantRating = functions.firestore
    .document("reviews/{reviewId}")
    .onWrite(async (change, context) => {
      const data = change.after.exists ?
      change.after.data() :
      change.before.data();
      const merchantId = data.merchantId;

      if (!merchantId) {
        console.log("Aucun ID de marchand trouvé. Arrêt de la fonction.");
        return null;
      }

      const merchantRef = admin.firestore().collection("users").doc(merchantId);

      const reviewsSnapshot = await admin
          .firestore()
          .collection("reviews")
          .where("merchantId", "==", merchantId)
          .get();

      const reviewCount = reviewsSnapshot.size;
      let averageRating = 0.0;

      if (reviewCount > 0) {
        const totalRating = reviewsSnapshot.docs.reduce((acc, doc) => {
          return acc + (doc.data().rating || 0);
        }, 0);
        averageRating = totalRating / reviewCount;
      }

      try {
        await merchantRef.update({
          reviewCount: reviewCount,
          averageRating: parseFloat(averageRating.toFixed(2)),
        });

        console.log(
            `Note mise à jour pour le marchand 
            ${merchantId}: ${averageRating.toFixed(
    2,
)} (${reviewCount} avis)`,
        );
      } catch (error) {
        console.error(
            `Échec de la mise à jour pour le marchand ${merchantId}:`,
            error,
        );
      }

      return null;
    });
