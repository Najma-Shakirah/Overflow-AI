exports.sendFloodAlert = functions.firestore
  .document('flood_alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alertData = snap.data();

    // Get all user tokens
    const tokensSnapshot = await admin.firestore().collection('user_tokens').get();
    const tokens = tokensSnapshot.docs.map(doc => doc.data().token);

    const multicastMessage = {
      notification: {
        title: `⚠️ ${alertData.severity} Flood Alert`,
        body: `${alertData.location}: ${alertData.message}`,
      },
      data: {
        alertId: context.params.alertId,
        location: alertData.location,
        severity: alertData.severity,
      },
      tokens: tokens,
    };

    // Send to all individual tokens
    if (tokens.length > 0) {
      await admin.messaging().sendEachForMulticast(multicastMessage);
    }

    // Also send to topic for any subscribers not in user_tokens
    await admin.messaging().send({
      ...multicastMessage,
      tokens: undefined,
      topic: 'flood_alerts',
    });
  });