/**
 * One-time migration script: normalize phone numbers to E.164 format.
 *
 * Why: The Firestore migration rule requires
 *   request.resource.data.phone == request.auth.token.phone_number
 * Firebase Auth always returns E.164 (+CCXXXXXXXXX). If existing Firestore
 * docs have local format (0XXXXXXXXX) or partial format (XXXXXXXXX), the
 * migration batch write fails with permission-denied.
 *
 * Run:
 *   node scripts/migrate_phone_formats.js
 *
 * Prerequisites:
 *   npm install firebase-admin
 *   Set GOOGLE_APPLICATION_CREDENTIALS to your service account JSON path, e.g.:
 *   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
 */

const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// ── Configuration ────────────────────────────────────────────────────────────
// Default country code used by your platform.
// Change this if your platform serves multiple countries or has mixed formats.
const DEFAULT_COUNTRY_CODE = '+966';

// Only migrate admin-pre-created accounts (createdBy != 'self').
// Self-registered users set their own phone via Firebase Auth — already correct.
const ONLY_ADMIN_CREATED = true;

// Set to false for a real run. true = only print what would change.
const DRY_RUN = true;
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Normalize a phone number to E.164 format.
 * Mirrors the Dart Validators.normalizePhone logic.
 */
function normalizePhone(localPhone, countryCode = DEFAULT_COUNTRY_CODE) {
  let cleaned = localPhone.replace(/[\s\-\(\)]/g, '');
  const code = countryCode.replace(/[\s\-]/g, '');

  if (cleaned.startsWith('+')) return cleaned;

  const codeDigits = code.replace('+', '');
  if (cleaned.startsWith(codeDigits)) return `+${cleaned}`;

  if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);

  return `${code}${cleaned}`;
}

async function run() {
  console.log(`\n=== Phone Migration Script ===`);
  console.log(`DRY_RUN: ${DRY_RUN}`);
  console.log(`DEFAULT_COUNTRY_CODE: ${DEFAULT_COUNTRY_CODE}`);
  console.log(`ONLY_ADMIN_CREATED: ${ONLY_ADMIN_CREATED}\n`);

  let query = db.collection('users');
  if (ONLY_ADMIN_CREATED) {
    // Admin-created docs have createdBy set to the admin's UID (not 'self')
    // We can't do != in Firestore, so we fetch all and filter in JS
  }

  const snapshot = await query.get();
  console.log(`Total user docs: ${snapshot.size}`);

  let toUpdate = 0;
  let alreadyCorrect = 0;
  let skipped = 0;

  const BATCH_SIZE = 400; // Firestore batch limit is 500
  let batch = db.batch();
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const phone = data.phone;
    const createdBy = data.createdBy;

    if (!phone) {
      skipped++;
      continue;
    }

    if (ONLY_ADMIN_CREATED && createdBy === 'self') {
      skipped++;
      continue;
    }

    const normalized = normalizePhone(phone);

    if (normalized === phone) {
      alreadyCorrect++;
      continue;
    }

    console.log(`  [${doc.id.substring(0, 8)}...] role=${data.role} "${phone}" → "${normalized}"`);
    toUpdate++;

    if (!DRY_RUN) {
      batch.update(doc.ref, {
        phone: normalized,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      batchCount++;

      if (batchCount >= BATCH_SIZE) {
        await batch.commit();
        console.log(`  Committed batch of ${batchCount}`);
        batch = db.batch();
        batchCount = 0;
      }
    }
  }

  if (!DRY_RUN && batchCount > 0) {
    await batch.commit();
    console.log(`  Committed final batch of ${batchCount}`);
  }

  console.log(`\n--- Summary ---`);
  console.log(`  Would update : ${toUpdate}`);
  console.log(`  Already E.164: ${alreadyCorrect}`);
  console.log(`  Skipped      : ${skipped}`);

  if (DRY_RUN) {
    console.log(`\nThis was a DRY RUN. Set DRY_RUN = false and re-run to apply changes.`);
  } else {
    console.log(`\nMigration complete.`);
  }
}

run().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
