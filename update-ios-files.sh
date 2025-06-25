#!/bin/bash

# iOS File Update Script
# This script downloads the updated iOS files and places them in the correct locations

echo "🍎 Starting iOS File Update..."

# Check if we're in the right directory
if [ ! -d "Sonetel Mobile" ]; then
    echo "❌ Error: Please run this script from the root directory of your iOS project"
    echo "   Make sure you can see the 'Sonetel Mobile' folder"
    exit 1
fi

# Create backup directory
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backup in $BACKUP_DIR..."

# Backup original files
cp "Sonetel Mobile/Models/AuthenticationManager.swift" "$BACKUP_DIR/" 2>/dev/null
cp "Sonetel Mobile/Views/CallsView.swift" "$BACKUP_DIR/" 2>/dev/null  
cp "Sonetel Mobile/Models/UserProfile.swift" "$BACKUP_DIR/" 2>/dev/null

echo "⬇️  Downloading updated files..."

# Download updated files from the development server
curl -s "http://localhost:3000/iOS-Updates/AuthenticationManager.swift" -o "Sonetel Mobile/Models/AuthenticationManager.swift"
curl -s "http://localhost:3000/iOS-Updates/CallsView.swift" -o "Sonetel Mobile/Views/CallsView.swift"
curl -s "http://localhost:3000/iOS-Updates/UserProfile.swift" -o "Sonetel Mobile/Models/UserProfile.swift"

# Check if downloads were successful
if [ $? -eq 0 ]; then
    echo "✅ Files updated successfully!"
    echo ""
    echo "📋 Updated files:"
    echo "   • Sonetel Mobile/Models/AuthenticationManager.swift"
    echo "   • Sonetel Mobile/Views/CallsView.swift" 
    echo "   • Sonetel Mobile/Models/UserProfile.swift"
    echo ""
    echo "🔄 Next steps:"
    echo "   1. Open Xcode"
    echo "   2. Clean build (Product → Clean Build Folder)"
    echo "   3. Build and run (⌘+R)"
    echo ""
    echo "💡 You should now see 'D' instead of 'J' in the top-left avatar!"
    echo ""
    echo "📦 Original files backed up to: $BACKUP_DIR"
else
    echo "❌ Error downloading files. Please check your internet connection."
    echo "   Make sure the development server is running on http://localhost:3000"
fi
