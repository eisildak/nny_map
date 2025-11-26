#!/bin/bash

# GitHub Pages deploy script

echo "🔨 Building Flutter web..."
flutter build web --release

echo "📦 Preparing deployment..."
cd build/web

echo "🌿 Initializing git in build/web..."
git init
git add -A
git commit -m "Deploy to GitHub Pages"

echo "🚀 Pushing to gh-pages branch..."
git push -f https://github.com/eisildak/nny_map.git HEAD:gh-pages

echo "🧹 Cleaning up..."
cd ../..

echo "✅ Deployment complete!"
echo "🌐 Your app will be available at: https://eisildak.github.io/nny_map/"
