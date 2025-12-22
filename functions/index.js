const admin = require("firebase-admin");
admin.initializeApp();

const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

// ✅ HTTP test function
exports.hellobacho = onRequest((req, res) => {
  res.send("🔥 Backend is working!");
});

// ✅ Firestore trigger (NEW BLOG)
exports.notifyFollowersOnNewBlog = onDocumentCreated(
  "blogs/{blogId}",
  async (event) => {
    const blogData = event.data.data();

    if (!blogData || !blogData.authorId) {
      console.log("❌ Blog has no authorId");
      return;
    }

    const authorId = blogData.authorId;

    console.log("📝 New blog by author:", authorId);
  }
);

