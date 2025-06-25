#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const http = require("http");

class iOSAutoSync {
  constructor() {
    this.baseUrl = "http://localhost:3000";
    this.syncInterval = 2000; // Check every 2 seconds
    this.projectRoot = process.cwd();
    this.lastSyncTime = {};

    // File mappings: server path -> local path
    this.fileMappings = {
      "/iOS-Updates/AuthenticationManager.swift":
        "Sonetel Mobile/Models/AuthenticationManager.swift",
      "/iOS-Updates/CallsView.swift": "Sonetel Mobile/Views/CallsView.swift",
      "/iOS-Updates/UserProfile.swift":
        "Sonetel Mobile/Models/UserProfile.swift",
    };

    this.init();
  }

  init() {
    console.log("🍎 iOS Auto-Sync Started");
    console.log(`📁 Project Root: ${this.projectRoot}`);
    console.log(`🔄 Sync Interval: ${this.syncInterval}ms`);
    console.log("📡 Watching for changes...\n");

    // Initial sync
    this.syncAllFiles();

    // Start continuous sync
    this.startWatching();

    // Handle graceful shutdown
    process.on("SIGINT", () => {
      console.log("\n🛑 Auto-sync stopped");
      process.exit(0);
    });
  }

  async syncAllFiles() {
    for (const [serverPath, localPath] of Object.entries(this.fileMappings)) {
      await this.syncFile(serverPath, localPath);
    }
  }

  async syncFile(serverPath, localPath) {
    try {
      const localFullPath = path.join(this.projectRoot, localPath);

      // Check if local file exists and get its modification time
      let localModTime = 0;
      if (fs.existsSync(localFullPath)) {
        const stats = fs.statSync(localFullPath);
        localModTime = stats.mtime.getTime();
      }

      // Get server file info
      const serverInfo = await this.getServerFileInfo(serverPath);
      if (!serverInfo) return;

      const serverModTime = new Date(serverInfo.lastModified).getTime();

      // Only sync if server file is newer
      if (serverModTime > localModTime) {
        const content = await this.downloadFile(serverPath);
        if (content) {
          // Create directory if it doesn't exist
          const localDir = path.dirname(localFullPath);
          if (!fs.existsSync(localDir)) {
            fs.mkdirSync(localDir, { recursive: true });
          }

          // Write file
          fs.writeFileSync(localFullPath, content);
          console.log(`✅ Updated: ${localPath}`);

          // Show what changed
          this.showChangesSummary(localPath);
        }
      }
    } catch (error) {
      console.error(`❌ Error syncing ${localPath}:`, error.message);
    }
  }

  getServerFileInfo(serverPath) {
    return new Promise((resolve) => {
      const options = {
        hostname: "localhost",
        port: 3000,
        path: serverPath,
        method: "HEAD",
      };

      const req = http.request(options, (res) => {
        resolve({
          lastModified:
            res.headers["last-modified"] || new Date().toISOString(),
          size: res.headers["content-length"],
        });
      });

      req.on("error", () => resolve(null));
      req.end();
    });
  }

  downloadFile(serverPath) {
    return new Promise((resolve) => {
      const options = {
        hostname: "localhost",
        port: 3000,
        path: serverPath,
        method: "GET",
      };

      const req = http.request(options, (res) => {
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => resolve(data));
      });

      req.on("error", (error) => {
        console.error(`❌ Download error:`, error.message);
        resolve(null);
      });
      req.end();
    });
  }

  showChangesSummary(filePath) {
    if (filePath.includes("AuthenticationManager.swift")) {
      console.log("   🔧 Added user name property and initial logic");
    } else if (filePath.includes("CallsView.swift")) {
      console.log("   👤 Updated profile avatar to use dynamic user initial");
    } else if (filePath.includes("UserProfile.swift")) {
      console.log("   📝 Enhanced UserProfile with email fallback logic");
    }
  }

  startWatching() {
    setInterval(async () => {
      await this.syncAllFiles();
    }, this.syncInterval);
  }

  async checkServerHealth() {
    try {
      const options = {
        hostname: "localhost",
        port: 3000,
        path: "/health",
        method: "GET",
        timeout: 1000,
      };

      return new Promise((resolve) => {
        const req = http.request(options, (res) => {
          resolve(res.statusCode === 200);
        });
        req.on("error", () => resolve(false));
        req.on("timeout", () => resolve(false));
        req.end();
      });
    } catch {
      return false;
    }
  }
}

// Check if we're in the right directory
if (!fs.existsSync("Sonetel Mobile")) {
  console.error(
    "❌ Error: Please run this from your iOS project root directory",
  );
  console.error('   Make sure you can see the "Sonetel Mobile" folder');
  process.exit(1);
}

// Start auto-sync
new iOSAutoSync();
