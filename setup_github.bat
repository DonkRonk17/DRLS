#!/bin/bash
# GitHub Repository Setup Commands for DRGUI
# Run these commands after creating the repository on GitHub

echo "🚀 Setting up GitHub repository for DRGUI..."

# Navigate to the DRGUI directory
cd "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI"

# Add the GitHub remote
git remote add origin https://github.com/DonkRonk17/DRGUI.git

# Verify the remote was added
echo "📡 Checking remote..."
git remote -v

# Push to GitHub
echo "📤 Pushing to GitHub..."
git push -u origin master

echo "✅ Repository should now be live at: https://github.com/DonkRonk17/DRGUI"
echo "🎉 DRGUI is now on GitHub!"