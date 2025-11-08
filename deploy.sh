#!/bin/bash
set -e

echo "🔨 Building Flutter web app..."
echo "class ApiKeys {
  static const String googleMapsApiKey = 'AIzaSyDWVBfYxASYj1aTqcS8pvHa67IDic4wthk';
}" > lib/config/api_keys.dart

flutter build web --release --base-href /nny_map/

echo "📦 Preparing deployment..."
cd build/web

echo "🚀 Deploying to gh-pages..."
git init
git add -A
git commit -m 'Deploy to GitHub Pages'
git branch -M gh-pages

echo "⬆️  Pushing to GitHub..."
git remote add origin https://github.com/eisildak/nny_map.git
git push -f origin gh-pages

echo "✅ Deployment complete!"
echo "🌐 Site will be live at: https://eisildak.github.io/nny_map/"
