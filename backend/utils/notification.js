import sendNotification from "./fcm.js";

const notify = async (registrationToken, title, body) => {
  try {
    if (!registrationToken || !title || !body) {
      console.log("❌ Missing required notification data");
      return;
    }

    const payload = {
      notification: {
        title,
        body,
      },
      data: {
        title,
        body,
      },
    };

    await sendNotification(registrationToken, payload); // ✅ token is passed separately
  } catch (error) {
    console.log("❌ Notification failed", error);
  }
};

export default notify;
