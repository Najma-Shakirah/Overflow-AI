const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Trigger when a new flood alert is added to Firestore
exports.sendFloodAlert = functions.firestore
  .document('flood_alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alertData = snap.data();
    
    const message = {
      notification: {
        title: `⚠️ ${alertData.severity} Flood Alert`,
        body: `${alertData.location}: ${alertData.message}`,
      },
      data: {
        alertId: context.params.alertId,
        location: alertData.location,
        severity: alertData.severity,
      },
      topic: 'flood_alerts', // Send to all subscribed users
    };

    try {
      await admin.messaging().send(message);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

// Manual trigger function for testing
exports.sendManualFloodAlert = functions.https.onCall(async (data, context) => {
  const message = {
    notification: {
      title: data.title || '⚠️ Flood Alert',
      body: data.body || 'Check the app for details',
    },
    topic: 'flood_alerts',
  };

  await admin.messaging().send(message);
  return { success: true };
});

// Scheduled function - Check water levels every hour
exports.checkWaterLevels = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    // Fetch water level data from your API or database
    const waterLevelsSnapshot = await admin.firestore()
      .collection('water_levels')
      .where('level', '>', 5) // Danger threshold
      .get();

    waterLevelsSnapshot.forEach(async (doc) => {
      const data = doc.data();
      
      // Create alert in Firestore (triggers sendFloodAlert function)
      await admin.firestore().collection('flood_alerts').add({
        location: data.location,
        severity: 'HIGH',
        message: `Water level at ${data.level}m - Take precautions!`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return null;
  });