# GitHub Repository Setup Instructions

## Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in as DonkRonk17
2. Click the **"+"** button in the top right corner
3. Select **"New repository"**
4. Fill in the details:
   - **Repository name**: `DRGUI`
   - **Description**: `Elite World of Warcraft UI addon with AI integration and desktop profile manager`
   - **Visibility**: Public (recommended for community sharing)
   - **Initialize**: 
     - ❌ Do NOT add README (we already have one)
     - ❌ Do NOT add .gitignore (we already have one)
     - ❌ Do NOT add license (we already have one)
5. Click **"Create repository"**

## Step 2: Connect Local Repository to GitHub

After creating the repository on GitHub, run these commands in PowerShell:

```powershell
# Navigate to the DRGUI folder
cd "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI_BK"

# Add the GitHub remote (replace YOUR_USERNAME if different)
git remote add origin https://github.com/DonkRonk17/DRGUI.git

# Push the code to GitHub
git push -u origin master
```

## Step 3: Create GitHub Release

1. Go to your repository: `https://github.com/DonkRonk17/DRGUI`
2. Click **"Releases"** (on the right side)
3. Click **"Create a new release"**
4. Fill in the release details:
   - **Tag version**: `v1.0.0`
   - **Release title**: `DRGUI v1.0.0 - Initial Production Release`
   - **Description**: Copy from `releases/v1.0/RELEASE_NOTES.md`
5. **Attach files**:
   - Upload `releases/v1.0/DRGUI_Profile_Manager.exe`
   - Optionally create a zip of the entire addon folder
6. Check **"Set as the latest release"**
7. Click **"Publish release"**

## Step 4: Repository Settings (Recommended)

### Topics (helps with discovery):
- `world-of-warcraft`
- `wow-addon`
- `elvui`
- `ui-framework`
- `python-desktop-app`
- `ai-integration`
- `profile-manager`

### Repository Description:
```
Elite World of Warcraft UI addon with AI integration and desktop profile manager. Auto-detects race/class/spec combinations, integrates 25+ addons, and includes a standalone Windows application for profile management.
```

### About Section:
- **Website**: Leave blank or add your personal site
- **Topics**: Add the topics listed above
- **Release**: Should show v1.0.0 after creating release

## Verification Checklist

After completing the setup:

- [ ] Repository is public and accessible
- [ ] README.md displays properly on the main page
- [ ] Release v1.0.0 is available with attached executable
- [ ] Repository has appropriate topics and description
- [ ] All files are properly committed and pushed
- [ ] .gitignore is working (no build files, etc.)
- [ ] License is visible in repository

## Alternative Push Commands

If you encounter authentication issues, you may need to use a Personal Access Token:

```powershell
# If using Personal Access Token (recommended)
git remote set-url origin https://DonkRonk17:YOUR_PERSONAL_ACCESS_TOKEN@github.com/DonkRonk17/DRGUI.git
git push -u origin master
```

## Repository URL

After setup, your repository will be available at:
**https://github.com/DonkRonk17/DRGUI**

## Next Steps

1. Share the repository URL with the WoW community
2. Post on r/wow, class Discord channels, and WoW forums
3. Submit to CurseForge and WoWInterface
4. Create documentation wiki if needed
5. Set up GitHub Actions for automated builds (optional)

## Troubleshooting

**Authentication Issues:**
- Use GitHub CLI: `gh auth login`
- Or create Personal Access Token in GitHub Settings > Developer settings

**Push Rejected:**
- Make sure repository is empty when you created it
- If not, use: `git push -f origin master` (only on first push)

**Large File Issues:**
- The executable (~11MB) should be fine
- If issues, use Git LFS: `git lfs track "*.exe"`

---

**Ready to launch! 🚀**

Your DRGUI addon is now ready for the World of Warcraft community!