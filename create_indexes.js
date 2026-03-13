// create_indexes.js
// Run: node create_indexes.js
// This script deploys Firestore composite indexes using Firebase CLI

const { execSync, exec } = require("child_process");
const path = require("path");
const fs = require("fs");

const projectId = "candoo-7ddfc";

function runCommand(cmd, description) {
  console.log(`\n⏳ ${description}...`);
  try {
    const output = execSync(cmd, {
      encoding: "utf8",
      stdio: ["inherit", "pipe", "pipe"],
      timeout: 120000, // 2 minutes
    });
    if (output) console.log(output);
    console.log(`✅ Done: ${description}`);
    return true;
  } catch (err) {
    console.error(`❌ Failed: ${description}`);
    if (err.stdout) console.log("STDOUT:", err.stdout);
    if (err.stderr) console.log("STDERR:", err.stderr);
    return false;
  }
}

// Verify the indexes file exists
const indexesFile = path.join(__dirname, "firestore.indexes.json");
if (!fs.existsSync(indexesFile)) {
  console.error("❌ firestore.indexes.json not found!");
  process.exit(1);
}

// Check if firebase CLI is available
console.log("🔍 Checking Firebase CLI...");
let firebaseCmd = "firebase";
try {
  execSync("firebase --version", { encoding: "utf8", stdio: "pipe" });
  console.log("✅ Firebase CLI found globally");
} catch {
  // Try npx
  console.log("Trying npx firebase...");
  firebaseCmd = "npx firebase-tools";
}

console.log("\n🚀 Deploying Firestore Indexes to project: " + projectId);
console.log("📄 Using indexes file: firestore.indexes.json\n");

// Check if firebase.json exists, if not create a minimal one
const firebaseJsonPath = path.join(__dirname, "firebase.json");
if (!fs.existsSync(firebaseJsonPath)) {
  console.log("📝 Creating minimal firebase.json...");
  const firebaseJson = {
    firestore: {
      rules: "firestore.rules",
      indexes: "firestore.indexes.json",
    },
  };
  fs.writeFileSync(firebaseJsonPath, JSON.stringify(firebaseJson, null, 2));
  console.log("✅ firebase.json created");
}

// Create minimal firestore.rules if not exists
const rulesPath = path.join(__dirname, "firestore.rules");
if (!fs.existsSync(rulesPath)) {
  console.log("📝 Creating minimal firestore.rules...");
  const rules = `rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}`;
  fs.writeFileSync(rulesPath, rules);
  console.log("✅ firestore.rules created");
}

// Deploy only Firestore indexes
const success = runCommand(
  `${firebaseCmd} deploy --only firestore:indexes --project ${projectId}`,
  "Deploying Firestore indexes"
);

if (success) {
  console.log("\n🎉 All Firestore indexes deployed successfully!");
  console.log(
    "⏳ Note: Indexes may take 1-5 minutes to build on Firebase servers."
  );
  console.log(
    "🔗 Check status at: https://console.firebase.google.com/project/" +
      projectId +
      "/firestore/indexes"
  );
} else {
  console.log(
    "\n⚠️  Automatic deployment failed. Try manually running this command:"
  );
  console.log(
    `   firebase deploy --only firestore:indexes --project ${projectId}`
  );
  console.log("\nOr go to Firebase Console and add indexes manually:");
  console.log(
    "🔗 https://console.firebase.google.com/project/" +
      projectId +
      "/firestore/indexes"
  );
}
