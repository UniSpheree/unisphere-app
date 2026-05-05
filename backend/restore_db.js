const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const DB_PATH = path.join(BASE_DIR, 'unisphere.db');

const src = process.argv[2];
if (!src) {
  console.error('Usage: node restore_db.js <path-to-db-file>');
  process.exit(1);
}

if (!fs.existsSync(src)) {
  console.error('Source file not found:', src);
  process.exit(1);
}

try {
  fs.copyFileSync(src, DB_PATH);
  console.log('Database restored to', DB_PATH);
} catch (e) {
  console.error('Failed to restore database:', e.message);
  process.exit(1);
}
