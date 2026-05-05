const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const DB_PATH = path.join(BASE_DIR, 'unisphere.db');
const BACKUPS_DIR = path.join(BASE_DIR, 'backups');

if (!fs.existsSync(DB_PATH)) {
  console.error('Database not found at', DB_PATH);
  process.exit(1);
}

fs.mkdirSync(BACKUPS_DIR, { recursive: true });
const stamp = new Date().toISOString().replace(/[:.]/g, '-');
const dest = path.join(BACKUPS_DIR, `unisphere-${stamp}.db`);

try {
  fs.copyFileSync(DB_PATH, dest);
  console.log('Backup created at', dest);
} catch (e) {
  console.error('Failed to create backup:', e.message);
  process.exit(1);
}
