# 🚀 FiveM Clothing/EUP Loader - Installation Guide

## Quick Start (5 Minutes)

### 1. ✅ Verify Installation
Your clothing loader is already installed! The resource is located at:
```
resources/[EUP]/clothing_loader/
```

Since you have `ensure [EUP]` in your server.cfg, the resource will load automatically.

### 2. 🔧 Install Build Dependencies (Choose One)

**Option A - Node.js (Recommended):**
1. Install Node.js from https://nodejs.org/
2. Open terminal/command prompt
3. Navigate to scripts folder:
   ```bash
   cd "C:\Users\Local User\Desktop\my-fivem\resources\[EUP]\clothing_loader\scripts"
   ```
4. Install dependencies:
   ```bash
   npm install
   ```

**Option B - Python:**
1. Install Python 3.7+ from https://python.org/
2. No additional packages needed!

### 3. 🎯 Add Your Clothing Files

Place your clothing packs in any of these locations:
- `resources/ef_clothes/`
- `resources/ef_clothes_new/`
- `resources/Male-EUP/`
- `resources/Female-EUP/`
- `resources/cfx_onx_gov_clothing_pack/`
- `resources/[EUP]/onx-evp-a-shared.pack/`
- `resources/[EUP]/onx-evp-b-wheels.pack/`
- `resources/[EUP]/onx-evp-c-pack.pack/`

### 4. 🔨 Build Your Clothing

**Windows:**
```batch
cd "resources\[EUP]\clothing_loader\scripts"
build.bat
```

**Linux/Mac:**
```bash
cd resources/[EUP]/clothing_loader/scripts
./build.sh
```

### 5. 🎮 Test In-Game

1. Start your FiveM server
2. Join the server
3. Use command: `/clothinginfo` (requires admin permissions)
4. Visit a clothing store to see your new items!

## 🔍 Troubleshooting

### Common Issues & Solutions

**❌ "clothing_loader resource not found"**
- ✅ Ensure the folder is in `resources/[EUP]/clothing_loader/`
- ✅ Check that `ensure [EUP]` is in your server.cfg

**❌ "Build script not working"**
- ✅ Install Node.js or Python
- ✅ Run from the correct directory
- ✅ Check file permissions

**❌ "Clothing not showing in-game"**
- ✅ Run the build script first
- ✅ Restart your server after building
- ✅ Check `/clothinginfo` for build status

**❌ "Floating torsos or missing textures"**
- ✅ Ensure YTD and YDD files are paired correctly
- ✅ Check that file names match expected patterns
- ✅ Verify clothing pack integrity

### Debug Mode

Enable detailed logging by editing `client.lua`:
```lua
local DEBUG_MODE = true  -- Change to true
```

### Admin Commands

- `/clothinginfo` - View build information
- `/rebuildclothing` - Rebuild clothing system
- `/validateclothing` - Validate loaded clothing (debug mode)

## 📋 System Requirements

- **FiveM Server** with QBX Core
- **illenium-appearance** resource
- **Node.js 14+** OR **Python 3.7+**
- **Windows/Linux/macOS** compatible

## 🎯 What This System Does

1. **Auto-Scans** your server for clothing files
2. **Removes Duplicates** automatically
3. **Generates Metadata** for proper FiveM integration
4. **Organizes Assets** in the correct structure
5. **Validates Clothing** to prevent common issues
6. **Provides Reports** on build status and errors

## 📊 Expected Results

After a successful build, you should see:
```
📊 Build Summary:
   Files Processed: 1,247
   Clothing Items: 1,198
   Meta Files: 49
   Duplicates Removed: 23
   Total Size: 156.7 MB
   Build Time: 2,341ms

🎉 Ready to use! Restart your FiveM server to load the new clothing.
```

## 🔄 Regular Maintenance

### Adding New Clothing
1. Place new files in monitored folders
2. Run build script: `npm run build`
3. Restart server or use `/rebuildclothing`

### Updating the System
1. Replace resource files
2. Run `/rebuildclothing` in-game
3. Check `/clothinginfo` for status

## 🆘 Getting Help

### Check These First:
1. **Build Reports**: Look at `build_info.json` and `build_report.txt`
2. **Server Console**: Check for error messages
3. **File Permissions**: Ensure scripts can read/write files
4. **Dependencies**: Verify Node.js or Python installation

### Error Codes:
- **Error 001**: Clothing folder not found
- **Error 002**: Invalid metadata format  
- **Error 003**: Duplicate file conflict
- **Error 004**: Permission denied
- **Error 005**: Invalid file format

## ✅ Success Checklist

- [ ] Resource folder exists in `resources/[EUP]/clothing_loader/`
- [ ] `ensure [EUP]` is in server.cfg
- [ ] Node.js or Python is installed
- [ ] Build script runs without errors
- [ ] `/clothinginfo` shows successful build
- [ ] Clothing appears in stores
- [ ] No console errors on server start

---

**🎉 Congratulations! Your FiveM Clothing/EUP Loader is ready to use!**

For advanced configuration and customization, see the main README.md file.
