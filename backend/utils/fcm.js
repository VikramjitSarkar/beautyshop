import admin from "firebase-admin";
import { User } from "../model/User.js";
import { Vendor } from "../model/Vendor.js";

admin.initializeApp({
  credential: admin.credential.cert({
    type: "service_account",
    project_id: "beautician-50d49",
    private_key_id: "7dc157670790421396bb00114b8e6973c777ac17",
    private_key:
      "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDjqFQMYZ1Ek714\nWYr/yaIoPFd+BCJPUbUK984IXZldo2rYv7mYjgICkxHOgIzL8ilLdDa6R+dUaAX0\nk5Be+KwWqrL5JNcd7xh+J7oDjZFAJmfIQyl0uP7blpr5hWsSwDXSu0sjW5LZr3LT\nC55I26mHQjbKFiOqx+4KOG6mTNHUJGetEaSZ3OuUKFj1z/El8XdD3ygeltOcxuG4\nR77Eczt+Trjf+/DsFC56M3waQjE4xj8nMCjCAHXv+wZCRYAOUN3VtLAKNclzzfBZ\nB6se1PWcKsr4v5LCi7KlQn6E7kMMR2BR5msUJxngeEZpjzsz4mJjC/XDnLyV/l1q\nNlN8IQdPAgMBAAECggEAUce5rZrxSl3CPfX4q0tM/6Qxj9i/VHwXC6IaNsIc4lje\nfI9fBhDZYwBe8K4YJflPYUYVlNRYoucdYI8T2TH+a8QVN8/GoP+vbj4qIbWcvI0v\nUe7ieQYts0dGU6VcYed/Tjyu0LxII//VQUAWs7iJDUg5c14BoQtiFPTRtta4t7pQ\nuwcWEeC5A80WIN1DQw3azf1cE6flxNPA4Adg7GTUFH40l7IDOtgjF2RCSWm/G9hz\nowMXgW/KAPDvit6A7he5YaXZsA+EZTXrZp28TTjcpz8hg+4J9SvFX5SyEnG1pfB/\n9lTBxyKGoQ2LD/T1//cVDiv7Vn5JvpbCAA6DSzvSkQKBgQDy88qEHGp1EkeCgMf1\nfBMcJKOvidOCl9w6iNIuvBoPaDoJx9gVYO52PAmlMMv0ZwqPGas1jR4OrTap3Dmw\nhl/9ZxM68Dy5w9nRL6rrs5wrY3vzXU0y/g2tV60OBkIZVkY+HStX2uKDdb27yvjO\nt3KHgnNaca5D8EQjpvCbvU6QfwKBgQDv4kIhGAtaElqa4Rpm9BDS0DLaSfCH/A3Z\nj7OqDnOJUOZ8LDOMrSQI8YwVbgwvBlBA1Z0mWhYe2qZM0YCEfSQzt5ZCUM11C9+F\nEmUgg0dXM3XcH+sIXaprJ9FZCcZDzSdJM6moxjqlWfbwiRx9O5bX48EtZUI0HDXC\nGNKwdQkhMQKBgHOy2dy0U5ZREDD79z3Wypr6b+Emt81XWI+fnMiY16hCsHD79NGp\niaZQzR8X7+kCMSsYxEoKXCgNIR0fPXHtbEUXEzdcNO8ab96I3tLEhDi9dcfdxOfl\nyMmmGUm2fT/nsCfgaEW8fWaxaZvG+1omTqpt21VVEfJUt35q/+aK7qEtAoGBAJWq\nS+oL72E2HFOPaIKdejWdcmzhPvII37dCwiyysYEV+Ye1qD/38oil8+mW7IEWZlHd\nNRwtjqmXb7Rz7cQ7s6+UtmoPsfB6BO4oqPGdFpCgacN6IpDop6ANir8Lqyi4Qe+Z\nDRxg+UwbEkfGtACqghWWYvtotuJ+S0gbZrBzhMuxAoGAQY5/aSCoBZMe+731vTcH\nJLwjV+a+fsElcKZW4VjohkIk14riglReC7fTQwLeJr9yuYkCCDlvg+4ok76hon+v\nRbU35KsXmjG6aRhExQ+5huPJ2dLQ9PeF3i/hgef/OEPcqFeGz56RRmrvILmLrj46\nhR0993mTXK3dEY4HELMFQ5A=\n-----END PRIVATE KEY-----\n",
    client_email:
      "firebase-adminsdk-fbsvc@beautician-50d49.iam.gserviceaccount.com",
    client_id: "114198951434679584146",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url:
      "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40beautician-50d49.iam.gserviceaccount.com",
    universe_domain: "googleapis.com",
  }),
  // databaseURL: '<your-database-url>'
});

const removeInvalidToken = async (token) => {
  await Promise.all([
    User.updateMany({ fcmToken: token }, { $unset: { fcmToken: "" } }),
    Vendor.updateMany({ fcmToken: token }, { $unset: { fcmToken: "" } }),
  ]);
  console.log(`🧹 Removed invalid FCM token: ${token}`);
};

// const sendNotification = async (token, payload) => {
//   try {
//     const response = await admin.messaging().send({
//       token,
//       notification: payload.notification,
//       data: payload.data,
//     });
//     console.log("✅ FCM notification sent:", response);
//   } catch (error) {
//     console.error("❌ Error sending FCM notification:", error.message);

//     if (
//       error.code === "messaging/registration-token-not-registered" ||
//       error.code === "messaging/invalid-argument"
//     ) {
//       await removeInvalidToken(token);
//     }
//   }
// };

// export default sendNotification;

const sendNotification = async (token, payload) => {
  try {
    const response = await admin.messaging().send({
      token, // ✅ MUST be a separate key
      notification: payload.notification,
      data: payload.data,
    });
    console.log("✅ FCM notification sent:", response);
  } catch (error) {
    console.error("❌ Error sending FCM notification:", error);
  }
};

export default sendNotification;
