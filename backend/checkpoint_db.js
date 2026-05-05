const Database = require("better-sqlite3");
const path = require("path");

const DB_PATH = path.join(__dirname, "unisphere.db");
const db = new Database(DB_PATH);

// Force WAL checkpoint
db.exec("PRAGMA wal_checkpoint(RESTART)");
console.log("WAL checkpointed to main DB");

// Close and reopen to finalize
db.close();
console.log("Database closed - WAL merged into main DB file");
