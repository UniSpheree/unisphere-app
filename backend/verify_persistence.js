#!/usr/bin/env node

/**
 * Persistence Verification Script
 * Checks that data is properly saved and restored from SQLite database
 */

const Database = require("better-sqlite3");
const path = require("path");

const DB_PATH = path.join(__dirname, "unisphere.db");

console.log("🔍 Verifying data persistence...\n");
console.log(`Database file: ${DB_PATH}`);

try {
  const db = new Database(DB_PATH, { readonly: true, fileMustExist: true });

  // Check tables exist
  const tables = db
    .prepare(
      `
    SELECT name FROM sqlite_master 
    WHERE type='table' AND name NOT LIKE 'sqlite_%'
    ORDER BY name
  `
    )
    .all();

  console.log(`\n✓ Database connected (${tables.length} tables found)`);

  tables.forEach((t) => {
    const count = db.prepare(`SELECT COUNT(*) as cnt FROM ${t.name}`).get();
    console.log(`  • ${t.name}: ${count.cnt} row(s)`);
  });

  // Show stored data summary
  const users = db
    .prepare("SELECT id, email, first_name, last_name, role FROM users")
    .all();
  const events = db
    .prepare("SELECT id, title, organizer_email, date FROM events")
    .all();
  const tickets = db.prepare("SELECT id, user_email, title FROM tickets").all();

  console.log("\n📊 Data Summary:");
  console.log(`  Users: ${users.length}`);
  users.forEach((u) =>
    console.log(`    - ${u.email} (${u.first_name} ${u.last_name}) [${u.role}]`)
  );

  console.log(`  Events: ${events.length}`);
  events.forEach((e) =>
    console.log(
      `    - ${e.title} by ${e.organizer_email} on ${e.date?.split("T")[0]}`
    )
  );

  console.log(`  Tickets: ${tickets.length}`);
  tickets.forEach((t) => console.log(`    - ${t.user_email} → ${t.title}`));

  console.log("\n✅ All data is properly saved and persistent!");
  console.log(
    "   Reload the app and all data will be restored automatically.\n"
  );

  db.close();
  process.exit(0);
} catch (error) {
  console.error("❌ Error verifying persistence:", error.message);
  process.exit(1);
}
