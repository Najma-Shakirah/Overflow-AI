importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyCicgJIs9rYtvqU3WVD6StNW6F8L9eCO_g",
  authDomain: "overflowai.firebaseapp.com",
  projectId: "overflowai",
  storageBucket: "overflowai.firebasestorage.app",
  messagingSenderId: "841934933765",
  appId: "1:841934933765:web:f5f43a78bc34d02f03b16c",
  measurementId: "G-DPZDSHCF3C"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received:', payload);
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  });
});