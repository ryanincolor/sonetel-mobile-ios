const express = require("express");
const http = require("http");
const app = express();
const server = http.createServer(app);
const port = 3000;

// Enable CORS and CSP headers for Builder.io VS Code extension
app.use((req, res, next) => {
  // CORS headers
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, DELETE, OPTIONS, PATCH",
  );
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization, x-builder-api-key, x-builder-user-token",
  );

  // CSP headers for Builder.io iframe support with relaxed restrictions
  res.header(
    "Content-Security-Policy",
    "frame-ancestors 'self' https://builder.io https://*.builder.io http://localhost:* vscode-webview:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https: data:; style-src 'self' 'unsafe-inline' https: data:;",
  );
  res.header("X-Frame-Options", "ALLOWALL");
  res.header("X-Content-Type-Options", "nosniff");

  // Additional headers for Builder.io compatibility
  res.header("Referrer-Policy", "no-referrer-when-downgrade");
  res.header("Permissions-Policy", "camera=(), microphone=(), geolocation=()");

  // Allow Builder.io to access cookies and localStorage
  res.header("Access-Control-Allow-Credentials", "true");

  // Builder.io specific headers
  res.header(
    "Access-Control-Expose-Headers",
    "x-builder-content-type, x-builder-target",
  );

  if (req.method === "OPTIONS") {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Request logging middleware to debug Builder.io requests
app.use((req, res, next) => {
  // Skip logging for static assets to reduce noise
  if (
    !req.url.match(/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/)
  ) {
    console.log(
      `📡 ${req.method} ${req.url} - Origin: ${req.headers.origin || "direct"}`,
    );
  }

  // Log requests that might be related to CodeChat or Builder.io
  if (
    req.url.includes("codechat") ||
    req.url.includes("chat") ||
    req.url.includes("status") ||
    req.url.includes("session") ||
    req.url.includes("launch") ||
    req.headers["user-agent"]?.includes("Builder") ||
    req.headers.origin?.includes("builder")
  ) {
    console.log(`🔍 BUILDER REQUEST: ${req.method} ${req.url}`);
    console.log("🔍 Origin:", req.headers.origin);
    console.log("🔍 User-Agent:", req.headers["user-agent"]?.substring(0, 100));
    if (req.body && Object.keys(req.body).length > 0) {
      console.log("🔍 Body:", req.body);
    }
  }
  next();
});

// Enable JSON parsing for API endpoints
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Serve static content with Builder.io integration for iOS development
app.get("/", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Sonetel Mobile - iOS Development with Builder.io</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                max-width: 800px;
                margin: 20px auto;
                padding: 20px;
                background-color: #f5f5f7;
                line-height: 1.6;
            }
            .container {
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            .design-container {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            }
            h1 { color: #1d1d1f; margin-top: 0; }
            h2 { color: #1d1d1f; margin-top: 30px; }
            .design-container h2 { color: white; }
            .ios-icon { font-size: 48px; margin-bottom: 20px; }
            .instructions {
                background: #f2f2f7;
                padding: 20px;
                border-radius: 8px;
                margin: 20px 0;
            }
            .design-instructions {
                background: rgba(255,255,255,0.1);
                padding: 20px;
                border-radius: 8px;
                margin: 20px 0;
                backdrop-filter: blur(10px);
            }
            code {
                background: #e8e8ed;
                padding: 4px 8px;
                border-radius: 4px;
                font-family: 'SF Mono', Monaco, monospace;
            }
            .design-container code {
                background: rgba(255,255,255,0.2);
                color: white;
            }
            .btn {
                display: inline-block;
                padding: 12px 24px;
                background: #007AFF;
                color: white;
                text-decoration: none;
                border-radius: 8px;
                margin: 10px 10px 10px 0;
                transition: background 0.3s ease;
            }
            .btn:hover {
                background: #0056CC;
            }
            .btn-secondary {
                background: #34C759;
            }
            .btn-secondary:hover {
                background: #28A745;
            }
            .design-playground {
                min-height: 400px;
                background: white;
                border-radius: 8px;
                margin: 20px 0;
                padding: 20px;
                border: 2px dashed #ccc;
            }
            .status {
                background: #d4edda;
                color: #155724;
                padding: 12px;
                border-radius: 6px;
                margin: 20px 0;
            }
            .workflow {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin: 20px 0;
            }
            .workflow-step {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 8px;
                text-align: center;
                border-left: 4px solid #007AFF;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="ios-icon">📱</div>
            <h1>Sonetel Mobile - iOS Development</h1>
            <p>This iOS SwiftUI project now integrates with Builder.io for enhanced design workflows!</p>

            <div class="status">
                <strong>🎉 Builder.io Integration Ready!</strong> You can now use Builder.io tools for design and automatically generate SwiftUI code.
            </div>

            <div class="instructions">
                <h3>📋 iOS Development (Primary):</h3>
                <ol>
                    <li>Open <code>Sonetel Mobile.xcodeproj</code> in Xcode</li>
                    <li>Build and run the project using Xcode's built-in simulator</li>
                    <li>The app source code is located in the <code>Sonetel Mobile/</code> directory</li>
                </ol>
            </div>

            <h2>🎨 Design-to-SwiftUI Workflow</h2>
            <div class="workflow">
                <div class="workflow-step">
                    <h4>1. Design</h4>
                    <p>Use Builder.io visual editor to create your UI components</p>
                </div>
                <div class="workflow-step">
                    <h4>2. Generate</h4>
                    <p>Convert designs to SwiftUI code automatically</p>
                </div>
                <div class="workflow-step">
                    <h4>3. Integrate</h4>
                    <p>Copy generated SwiftUI code into your Xcode project</p>
                </div>
            </div>

            <a href="/design" class="btn">🎨 Open Design Playground</a>
            <a href="/swiftui-generator" class="btn btn-secondary">⚡ SwiftUI Code Generator</a>
        </div>

        <div class="design-container">
            <h2>🚀 Builder.io Design Tools</h2>
            <p>Use these tools to create beautiful UIs and automatically generate SwiftUI code for your iOS app.</p>

            <div class="design-instructions">
                <h3>✨ Enhanced Workflow:</h3>
                <ol>
                    <li>Design your UI components using the visual playground below</li>
                    <li>Use Builder.io's drag-and-drop interface</li>
                    <li>Generate production-ready SwiftUI code</li>
                    <li>Copy the code directly into your Xcode project</li>
                </ol>
            </div>

            <div id="builder-playground" class="design-playground">
                <div style="text-align: center; padding-top: 150px; color: #666;">
                    <p>🎨 Builder.io Visual Editor will load here</p>
                    <p>Create your iOS UI components visually and get SwiftUI code automatically!</p>
                </div>
            </div>
        </div>

        <script>
            // Builder.io iframe compatibility
            if (window.parent && window.parent !== window) {
                // Running in Builder.io iframe
                console.log('🎨 Running in Builder.io iframe');

                // Send ready message to Builder.io
                window.parent.postMessage({
                    type: 'builder-ready',
                    framework: 'swiftui',
                    capabilities: ['code-generation', 'design-import']
                }, '*');
            }

            // Builder.io integration will be initialized here
            console.log('🎨 Builder.io iOS Design Environment Ready!');

            // Add interactive functionality for the design playground
            function initializeBuilderPlayground() {
                const playground = document.getElementById('builder-playground');
                playground.innerHTML = \`
                    <div style="text-align: center; padding: 20px;">
                        <h3>🎨 Design Your SwiftUI Components</h3>
                        <p>This playground will integrate with Builder.io's visual editor</p>
                        <div style="margin: 20px 0;">
                            <button onclick="generateSwiftUICode()" style="padding: 10px 20px; background: #007AFF; color: white; border: none; border-radius: 6px; cursor: pointer;">
                                Generate SwiftUI Code
                            </button>
                        </div>
                        <div id="generated-code" style="background: #f8f9fa; padding: 20px; border-radius: 6px; margin-top: 20px; text-align: left; font-family: monospace; white-space: pre-wrap; display: none;"></div>
                    </div>
                \`;
            }

            function generateSwiftUICode() {
                const codeOutput = document.getElementById('generated-code');
                codeOutput.style.display = 'block';
                codeOutput.textContent = \`// Generated SwiftUI Code
import SwiftUI

struct CustomView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello, SwiftUI!")
                .font(.title)
                .foregroundColor(.primary)

            Button("Tap Me") {
                // Action here
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    CustomView()
}\`;
            }

            // Initialize the playground
            setTimeout(initializeBuilderPlayground, 1000);
        </script>
    </body>
    </html>
  `);
});

// Design playground endpoint with comprehensive functionality
app.get("/design", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>SwiftUI Design Playground</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0;
                padding: 20px;
                background: #f5f5f7;
            }
            .header {
                background: white;
                padding: 20px;
                border-radius: 12px;
                margin-bottom: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .design-area {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                height: calc(100vh - 200px);
            }
            .visual-editor {
                background: white;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .code-output {
                background: #1e1e1e;
                color: #d4d4d4;
                border-radius: 12px;
                padding: 20px;
                font-family: 'SF Mono', Monaco, monospace;
                overflow: auto;
            }
            .component-library {
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .component-item {
                display: inline-block;
                background: #007AFF;
                color: white;
                padding: 8px 12px;
                margin: 5px;
                border-radius: 6px;
                cursor: pointer;
                font-size: 12px;
            }
            .btn {
                background: #34C759;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 6px;
                cursor: pointer;
                margin: 5px;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🎨 SwiftUI Design Playground</h1>
            <p>Design your iOS components visually and generate SwiftUI code automatically</p>
            <a href="/" style="color: #007AFF; text-decoration: none;">← Back to Main</a>
        </div>

        <div class="design-area">
            <div class="visual-editor">
                <h3>Visual Editor</h3>
                <div class="component-library">
                    <h4>Components</h4>
                    <div class="component-item" onclick="addComponent('VStack')">VStack</div>
                    <div class="component-item" onclick="addComponent('HStack')">HStack</div>
                    <div class="component-item" onclick="addComponent('Text')">Text</div>
                    <div class="component-item" onclick="addComponent('Button')">Button</div>
                    <div class="component-item" onclick="addComponent('Image')">Image</div>
                    <div class="component-item" onclick="addComponent('TextField')">TextField</div>
                </div>

                <div id="canvas" style="border: 2px dashed #ccc; min-height: 300px; padding: 20px; background: white; border-radius: 8px;">
                    <p style="text-align: center; color: #666; margin-top: 100px;">Drop components here or click components above to add them</p>
                </div>

                <button class="btn" onclick="generateCode()">Generate SwiftUI Code</button>
                <button class="btn" onclick="clearCanvas()">Clear Canvas</button>
            </div>

            <div class="code-output">
                <h3 style="color: #569CD6;">Generated SwiftUI Code</h3>
                <pre id="generated-code">// Your SwiftUI code will appear here
// Add components from the left panel to get started

import SwiftUI

struct GeneratedView: View {
    var body: some View {
        VStack {
            // Components will be added here
        }
        .padding()
    }
}

#Preview {
    GeneratedView()
}</pre>
            </div>
        </div>

        <script>
            let components = [];

            function addComponent(type) {
                const component = { type, id: Date.now() };
                components.push(component);
                updateCanvas();
                generateCode();
            }

            function updateCanvas() {
                const canvas = document.getElementById('canvas');
                if (components.length === 0) {
                    canvas.innerHTML = '<p style="text-align: center; color: #666; margin-top: 100px;">Drop components here or click components above to add them</p>';
                    return;
                }

                canvas.innerHTML = components.map(comp =>
                    \`<div style="background: #e3f2fd; padding: 10px; margin: 5px; border-radius: 6px; border-left: 4px solid #2196f3;">
                        \${comp.type} <button onclick="removeComponent(\${comp.id})" style="float: right; background: #f44336; color: white; border: none; border-radius: 3px; padding: 2px 6px; cursor: pointer;">×</button>
                    </div>\`
                ).join('');
            }

            function removeComponent(id) {
                components = components.filter(comp => comp.id !== id);
                updateCanvas();
                generateCode();
            }

            function clearCanvas() {
                components = [];
                updateCanvas();
                generateCode();
            }

            function generateCode() {
                const codeElement = document.getElementById('generated-code');

                if (components.length === 0) {
                    codeElement.textContent = \`// Your SwiftUI code will appear here
// Add components from the left panel to get started

import SwiftUI

struct GeneratedView: View {
    var body: some View {
        VStack {
            // Components will be added here
        }
        .padding()
    }
}

#Preview {
    GeneratedView()
}\`;
                    return;
                }

                const swiftUIComponents = components.map(comp => {
                    switch(comp.type) {
                        case 'VStack':
                            return '            VStack {\\n                // Add content here\\n            }';
                        case 'HStack':
                            return '            HStack {\\n                // Add content here\\n            }';
                        case 'Text':
                            return '            Text("Hello, World!")\\n                .font(.title)';
                        case 'Button':
                            return \`            Button("Tap Me") {
                // Action here
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)\`;
                        case 'Image':
                            return '            Image(systemName: "star.fill")\\n                .foregroundColor(.yellow)';
                        case 'TextField':
                            return '            TextField("Enter text", text: $textInput)\\n                .textFieldStyle(RoundedBorderTextFieldStyle())';
                        default:
                            return \`            // \${comp.type}\`;
                    }
                }).join('\\n\\n');

                const fullCode = \`import SwiftUI

struct GeneratedView: View {
    @State private var textInput = ""

    var body: some View {
        VStack(spacing: 20) {
\${swiftUIComponents}
        }
        .padding()
    }
}

#Preview {
    GeneratedView()
}\`;

                codeElement.textContent = fullCode;
            }
        </script>
    </body>
    </html>
  `);
});

// CodeChat endpoints for Builder.io AI chat functionality
app.get("/codechat", (req, res) => {
  res.json({
    status: "connected",
    version: "1.0.0",
    capabilities: ["code-generation", "swiftui", "chat"],
    framework: "swiftui",
  });
});

app.get("/api/codechat", (req, res) => {
  res.json({
    status: "connected",
    version: "1.0.0",
    capabilities: ["code-generation", "swiftui", "chat"],
    framework: "swiftui",
  });
});

app.get("/api/v1/codechat/status", (req, res) => {
  res.json({
    status: "connected",
    version: "1.0.0",
    capabilities: ["code-generation", "swiftui", "chat"],
    framework: "swiftui",
  });
});

app.options("/api/v1/codechat/*", (req, res) => {
  res.status(200).end();
});

app.options("/codechat/*", (req, res) => {
  res.status(200).end();
});

// Screenshot API for Builder.io
app.get("/api/screenshot", (req, res) => {
  // Mock screenshot response
  res.json({
    success: true,
    url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    width: 1200,
    height: 800,
    timestamp: Date.now(),
  });
});

app.post("/api/screenshot", (req, res) => {
  // Mock screenshot response
  res.json({
    success: true,
    url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    width: 1200,
    height: 800,
    timestamp: Date.now(),
  });
});

app.get("/screenshot", (req, res) => {
  // Alternative screenshot endpoint
  res.json({
    success: true,
    url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    width: 1200,
    height: 800,
  });
});

// Builder.io server status and session endpoints
app.get("/api/launch/status", (req, res) => {
  res.json({
    status: "running",
    server: "ready",
    port: 3000,
    framework: "swiftui",
    timestamp: Date.now(),
  });
});

app.post("/api/launch/status", (req, res) => {
  res.json({
    status: "running",
    server: "ready",
    port: 3000,
    framework: "swiftui",
    timestamp: Date.now(),
  });
});

app.get("/api/session/init", (req, res) => {
  res.json({
    success: true,
    sessionId: `session_${Date.now()}`,
    framework: "swiftui",
    capabilities: ["code-generation", "design-import", "live-editing"],
    timestamp: Date.now(),
  });
});

app.post("/api/session/init", (req, res) => {
  res.json({
    success: true,
    sessionId: `session_${Date.now()}`,
    framework: "swiftui",
    capabilities: ["code-generation", "design-import", "live-editing"],
    timestamp: Date.now(),
  });
});

app.get("/api/session/status", (req, res) => {
  res.json({
    active: true,
    connected: true,
    framework: "swiftui",
    timestamp: Date.now(),
  });
});

app.post("/api/session/status", (req, res) => {
  res.json({
    active: true,
    connected: true,
    framework: "swiftui",
    timestamp: Date.now(),
  });
});

// Launch server endpoints (based on error messages)
app.get("/launch", (req, res) => {
  res.json({
    status: "ready",
    server: "running",
    framework: "swiftui",
    port: 3000,
  });
});

app.post("/launch", (req, res) => {
  res.json({
    status: "ready",
    server: "running",
    framework: "swiftui",
    port: 3000,
  });
});

app.get("/server/status", (req, res) => {
  res.json({
    running: true,
    framework: "swiftui",
    port: 3000,
    timestamp: Date.now(),
  });
});

app.post("/server/status", (req, res) => {
  res.json({
    running: true,
    framework: "swiftui",
    port: 3000,
    timestamp: Date.now(),
  });
});

// Builder.io authentication and token endpoints
app.get("/api/auth/token", (req, res) => {
  res.json({
    token: `mock_token_${Date.now()}`,
    expires: Date.now() + 3600000, // 1 hour
    type: "bearer",
  });
});

app.post("/api/auth/token", (req, res) => {
  res.json({
    token: `mock_token_${Date.now()}`,
    expires: Date.now() + 3600000,
    type: "bearer",
  });
});

app.get("/api/auth/status", (req, res) => {
  res.json({
    authenticated: true,
    user: "developer",
    permissions: ["read", "write", "admin"],
  });
});

// Builder.io workspace endpoints
app.get("/api/workspace/info", (req, res) => {
  res.json({
    name: "Sonetel Mobile",
    framework: "swiftui",
    type: "ios",
    rootDir: process.cwd(),
    srcDir: "Sonetel Mobile/Views",
  });
});

// Builder.io IDE integration endpoints
app.get("/api/ide/status", (req, res) => {
  res.json({
    connected: true,
    editor: "vscode",
    framework: "swiftui",
  });
});

app.post("/api/ide/open", (req, res) => {
  const { file, line } = req.body;
  console.log(`📝 IDE open request: ${file}:${line || 1}`);
  res.json({ opened: true, file, line });
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    message: "iOS development environment with Builder.io integration ready",
    features: [
      "SwiftUI Design Playground",
      "Code Generator",
      "Template Library",
      "Builder.io Integration",
      "VS Code Extension Support",
    ],
  });
});

// Handle WebSocket upgrade for CodeChat
server.on("upgrade", (request, socket, head) => {
  if (request.url?.includes("/codechat")) {
    // Mock WebSocket response for CodeChat
    const key = request.headers["sec-websocket-key"];
    const acceptKey = require("crypto")
      .createHash("sha1")
      .update(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
      .digest("base64");

    const responseHeaders = [
      "HTTP/1.1 101 Switching Protocols",
      "Upgrade: websocket",
      "Connection: Upgrade",
      `Sec-WebSocket-Accept: ${acceptKey}`,
      "Sec-WebSocket-Protocol: codechat",
      "",
    ].join("\r\n");

    socket.write(responseHeaders);

    // Send a welcome message
    setTimeout(() => {
      const message = JSON.stringify({
        type: "welcome",
        content: "CodeChat connected! I can help you generate SwiftUI code.",
        capabilities: ["code-generation", "swiftui", "ios"],
      });

      // Simple WebSocket frame (text frame, no masking)
      const frame = Buffer.concat([
        Buffer.from([0x81]), // FIN + text frame
        Buffer.from([message.length]), // Payload length
        Buffer.from(message, "utf8"), // Payload
      ]);

      socket.write(frame);
    }, 100);

    socket.on("data", (data) => {
      // Handle incoming WebSocket messages
      console.log("📞 CodeChat message received");
    });

    socket.on("close", () => {
      console.log("📞 CodeChat disconnected");
    });
  } else {
    socket.destroy();
  }
});

server.listen(port, () => {
  console.log(`🍎 iOS Development Server running at http://localhost:${port}`);
  console.log(`📱 Open Sonetel Mobile.xcodeproj in Xcode to start developing!`);
  console.log(`💬 CodeChat WebSocket ready at ws://localhost:${port}/codechat`);
});
