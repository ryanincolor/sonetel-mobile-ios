module.exports = {
  // Builder.io configuration for iOS SwiftUI project
  framework: "swiftui",
  target: "ios",

  // API configuration
  apiKey: process.env.BUILDER_API_KEY || "demo-key",
  apiHost: "http://localhost:3000",

  // SwiftUI specific settings
  output: {
    directory: "Sonetel Mobile/Views/",
    extension: ".swift",
    format: "swiftui",
  },

  // Component generation settings
  components: {
    directory: "Sonetel Mobile/Views/Components/",
    prefix: "",
    suffix: "View",
  },

  // Code generation options
  codeGeneration: {
    typescript: false,
    swiftui: true,
    imports: ["SwiftUI"],
    preview: true,
  },

  // Development server settings
  devServer: {
    port: 3000,
    host: "localhost",
    https: false,
  },

  // Builder.io specific configuration
  builder: {
    // Enable real-time editing
    liveEditing: true,

    // Component library
    componentLibrary: true,

    // Custom components for SwiftUI
    customComponents: [
      {
        name: "SwiftUIText",
        input: "Text",
        output: "Text",
      },
      {
        name: "SwiftUIButton",
        input: "Button",
        output: "Button",
      },
      {
        name: "SwiftUIImage",
        input: "Image",
        output: "AsyncImage",
      },
      {
        name: "SwiftUIStack",
        input: "Box",
        output: "VStack",
      },
    ],
  },

  // Plugins and extensions
  plugins: [
    {
      name: "swiftui-converter",
      enabled: true,
      options: {
        generatePreviews: true,
        useStateManagement: true,
      },
    },
  ],
};
