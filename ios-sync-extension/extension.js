const vscode = require("vscode");
const fs = require("fs");
const path = require("path");
const http = require("http");

let syncInterval;
let statusBarItem;
let isActive = false;

const fileMappings = {
  "/iOS-Updates/AuthenticationManager.swift":
    "Sonetel Mobile/Models/AuthenticationManager.swift",
  "/iOS-Updates/CallsView.swift": "Sonetel Mobile/Views/CallsView.swift",
  "/iOS-Updates/UserProfile.swift": "Sonetel Mobile/Models/UserProfile.swift",
};

function activate(context) {
  console.log("🍎 iOS Auto-Sync extension is now active!");

  // Create status bar item
  statusBarItem = vscode.window.createStatusBarItem(
    vscode.StatusBarAlignment.Right,
    100,
  );
  statusBarItem.command = "iosAutoSync.start";
  updateStatusBar("stopped");
  statusBarItem.show();

  // Register commands
  const startCommand = vscode.commands.registerCommand(
    "iosAutoSync.start",
    startAutoSync,
  );
  const stopCommand = vscode.commands.registerCommand(
    "iosAutoSync.stop",
    stopAutoSync,
  );
  const syncNowCommand = vscode.commands.registerCommand(
    "iosAutoSync.syncNow",
    syncNow,
  );
  const openXcodeCommand = vscode.commands.registerCommand(
    "iosAutoSync.openXcode",
    openXcode,
  );

  context.subscriptions.push(
    startCommand,
    stopCommand,
    syncNowCommand,
    openXcodeCommand,
    statusBarItem,
  );

  // Auto-start if enabled
  const config = vscode.workspace.getConfiguration("iosAutoSync");
  if (config.get("enabled")) {
    startAutoSync();
  }
}

function startAutoSync() {
  if (isActive) {
    vscode.window.showInformationMessage("🍎 iOS Auto-Sync is already running");
    return;
  }

  const config = vscode.workspace.getConfiguration("iosAutoSync");
  const interval = config.get("interval", 2000);

  isActive = true;
  updateStatusBar("syncing");

  vscode.window.showInformationMessage("🍎 iOS Auto-Sync started");

  // Initial sync
  syncNow();

  // Start interval
  syncInterval = setInterval(syncNow, interval);
}

function stopAutoSync() {
  if (!isActive) {
    vscode.window.showInformationMessage("🍎 iOS Auto-Sync is not running");
    return;
  }

  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }

  isActive = false;
  updateStatusBar("stopped");
  vscode.window.showInformationMessage("🛑 iOS Auto-Sync stopped");
}

async function syncNow() {
  const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
  if (!workspaceFolder) {
    vscode.window.showErrorMessage("❌ No workspace folder found");
    return;
  }

  const config = vscode.workspace.getConfiguration("iosAutoSync");
  const serverUrl = config.get("serverUrl", "http://localhost:3000");
  const showNotifications = config.get("showNotifications", true);

  try {
    for (const [serverPath, localPath] of Object.entries(fileMappings)) {
      await syncFile(
        serverUrl,
        serverPath,
        localPath,
        workspaceFolder.uri.fsPath,
        showNotifications,
      );
    }
    updateStatusBar("synced");
  } catch (error) {
    updateStatusBar("error");
    vscode.window.showErrorMessage(`❌ Sync error: ${error.message}`);
  }
}

async function syncFile(
  serverUrl,
  serverPath,
  localPath,
  workspaceRoot,
  showNotifications,
) {
  try {
    const localFullPath = path.join(workspaceRoot, localPath);

    // Check local file modification time
    let localModTime = 0;
    if (fs.existsSync(localFullPath)) {
      const stats = fs.statSync(localFullPath);
      localModTime = stats.mtime.getTime();
    }

    // Get server file info
    const serverInfo = await getServerFileInfo(serverUrl, serverPath);
    if (!serverInfo) return;

    const serverModTime = new Date(serverInfo.lastModified).getTime();

    // Only sync if server file is newer
    if (serverModTime > localModTime) {
      const content = await downloadFile(serverUrl, serverPath);
      if (content) {
        // Create directory if needed
        const localDir = path.dirname(localFullPath);
        if (!fs.existsSync(localDir)) {
          fs.mkdirSync(localDir, { recursive: true });
        }

        // Write file
        fs.writeFileSync(localFullPath, content);

        if (showNotifications) {
          vscode.window.showInformationMessage(
            `✅ Updated: ${path.basename(localPath)}`,
          );
        }

        // Open file in editor if it's a key file
        if (localPath.includes("CallsView.swift")) {
          const document =
            await vscode.workspace.openTextDocument(localFullPath);
          vscode.window.showTextDocument(document, { preview: false });
        }
      }
    }
  } catch (error) {
    console.error(`Error syncing ${localPath}:`, error);
  }
}

function getServerFileInfo(serverUrl, serverPath) {
  return new Promise((resolve) => {
    const url = new URL(serverPath, serverUrl);
    const options = {
      hostname: url.hostname,
      port: url.port || 3000,
      path: url.pathname,
      method: "HEAD",
    };

    const req = http.request(options, (res) => {
      resolve({
        lastModified: res.headers["last-modified"] || new Date().toISOString(),
        size: res.headers["content-length"],
      });
    });

    req.on("error", () => resolve(null));
    req.end();
  });
}

function downloadFile(serverUrl, serverPath) {
  return new Promise((resolve) => {
    const url = new URL(serverPath, serverUrl);
    const options = {
      hostname: url.hostname,
      port: url.port || 3000,
      path: url.pathname,
      method: "GET",
    };

    const req = http.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => resolve(data));
    });

    req.on("error", () => resolve(null));
    req.end();
  });
}

function updateStatusBar(status) {
  switch (status) {
    case "syncing":
      statusBarItem.text = "$(sync~spin) iOS Syncing...";
      statusBarItem.tooltip = "iOS Auto-Sync is running";
      statusBarItem.backgroundColor = undefined;
      break;
    case "synced":
      statusBarItem.text = "$(check) iOS Synced";
      statusBarItem.tooltip = "iOS files are up to date";
      statusBarItem.backgroundColor = undefined;
      break;
    case "error":
      statusBarItem.text = "$(error) iOS Sync Error";
      statusBarItem.tooltip = "iOS Auto-Sync encountered an error";
      statusBarItem.backgroundColor = new vscode.ThemeColor(
        "statusBarItem.errorBackground",
      );
      break;
    case "stopped":
    default:
      statusBarItem.text = "$(circle-large-outline) iOS Sync";
      statusBarItem.tooltip = "Click to start iOS Auto-Sync";
      statusBarItem.backgroundColor = undefined;
      break;
  }
}

function openXcode() {
  const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
  if (!workspaceFolder) {
    vscode.window.showErrorMessage("❌ No workspace folder found");
    return;
  }

  const xcodeProjectPath = path.join(
    workspaceFolder.uri.fsPath,
    "Sonetel Mobile.xcodeproj",
  );
  if (fs.existsSync(xcodeProjectPath)) {
    vscode.env.openExternal(vscode.Uri.file(xcodeProjectPath));
    vscode.window.showInformationMessage("📱 Opening project in Xcode...");
  } else {
    vscode.window.showErrorMessage("❌ Xcode project not found");
  }
}

function deactivate() {
  stopAutoSync();
}

module.exports = {
  activate,
  deactivate,
};
