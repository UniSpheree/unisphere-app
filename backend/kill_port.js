const { execSync } = require("child_process");
const os = require("os");

const PORT = 8000;

try {
  if (os.platform() === "win32") {
    // Windows: use netstat and taskkill
    try {
      const output = execSync(
        `netstat -ano | findstr :${PORT}`,
        { encoding: "utf-8" }
      );
      const lines = output.split("\n").filter((line) => line.trim());
      if (lines.length > 0) {
        const parts = lines[0].split(/\s+/);
        const pid = parts[parts.length - 1];
        if (pid && pid !== "PID") {
          console.log(`Killing process ${pid} on port ${PORT}...`);
          execSync(`taskkill /PID ${pid} /F`);
          console.log(`Port ${PORT} is now free`);
        }
      } else {
        console.log(`No process found on port ${PORT}`);
      }
    } catch (e) {
      console.log(`No process found on port ${PORT}`);
    }
  } else {
    // macOS/Linux: use lsof
    try {
      const output = execSync(`lsof -i :${PORT}`, { encoding: "utf-8" });
      const lines = output.split("\n");
      if (lines.length > 1) {
        const parts = lines[1].split(/\s+/);
        const pid = parts[1];
        console.log(`Killing process ${pid} on port ${PORT}...`);
        execSync(`kill -9 ${pid}`);
        console.log(`Port ${PORT} is now free`);
      }
    } catch (e) {
      console.log(`No process found on port ${PORT}`);
    }
  }
} catch (e) {
  console.error("Error killing port:", e.message);
  process.exit(1);
}
