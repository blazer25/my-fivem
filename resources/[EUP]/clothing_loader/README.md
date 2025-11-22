# FiveM Clothing/EUP Loader System

A complete, automated clothing and EUP (Emergency Uniform Pack) loader system for FiveM servers using QBX Core and illenium-appearance.

## 🚀 Features

- **Auto-Detection**: Automatically scans and detects clothing files from multiple sources
- **Duplicate Removal**: Intelligent duplicate detection and removal
- **Metadata Generation**: Auto-generates proper shop_ped_apparel.meta files
- **Multi-Format Support**: Supports YTD, YDD, YFT, YTF files
- **Cross-Platform**: Works on Windows, Linux, and macOS
- **Multiple Languages**: Node.js and Python implementations
- **Integration Ready**: Works seamlessly with illenium-appearance and QBX Core

## 📁 Supported Clothing Packs

The system automatically scans for these clothing pack folders:

- `ef_clothes/`
- `ef_clothes_new/`
- `Male-EUP/`
- `Female-EUP/`
- `cfx_onx_gov_clothing_pack/`
- `onx-evp-a-shared.pack/`
- `onx-evp-b-wheels.pack/`
- `onx-evp-c-pack.pack/`

## 🛠️ Installation

1. **Place the resource**: Copy the `clothing_loader` folder to `resources/[EUP]/`

2. **Add to server.cfg**:
   ```cfg
   ensure clothing_loader
   ```

3. **Install dependencies** (choose one):
   
   **Option A - Node.js** (Recommended):
   ```bash
   cd resources/[EUP]/clothing_loader/scripts
   npm install
   ```
   
   **Option B - Python**:
   - Ensure Python 3.7+ is installed
   - No additional packages required

## 🔧 Usage

### Automatic Build

**Windows:**
```batch
cd resources/[EUP]/clothing_loader/scripts
build.bat
```

**Linux/Mac:**
```bash
cd resources/[EUP]/clothing_loader/scripts
./build.sh
```

### Manual Build

**Node.js:**
```bash
cd resources/[EUP]/clothing_loader/scripts
node build_clothing.js
```

**Python:**
```bash
cd resources/[EUP]/clothing_loader/scripts
python build_clothing.py
```

### In-Game Commands

- `/clothinginfo` - View build information (Admin only)
- `/rebuildclothing` - Trigger a rebuild (Admin only)
- `/validateclothing` - Validate loaded clothing (Debug mode)

## 📋 Build Process

The build system performs these steps:

1. **Scan**: Searches all configured directories for clothing files
2. **Detect**: Identifies file types and removes duplicates
3. **Process**: Extracts metadata from existing .meta files
4. **Generate**: Creates unified metadata files
5. **Copy**: Moves all assets to the stream folder
6. **Report**: Generates detailed build reports

## 🗂️ File Structure

```
clothing_loader/
├── fxmanifest.lua          # Resource manifest
├── client.lua              # Client-side validation
├── server.lua              # Server-side management
├── README.md               # This file
├── data/                   # Generated metadata
│   ├── shop_ped_apparel.meta
│   ├── componentsets.meta
│   └── pedaccessories.meta
├── stream/                 # Auto-populated clothing files
│   └── (YTD/YDD/YFT/YTF files)
└── scripts/                # Build automation
    ├── build_clothing.js   # Node.js builder
    ├── build_clothing.py   # Python builder
    ├── build.bat          # Windows batch file
    ├── build.sh           # Linux/Mac shell script
    └── package.json       # Node.js dependencies
```

## ⚙️ Configuration

### Scan Folders

Edit the `scan_folders` array in the build scripts to add/remove clothing pack folders:

**Node.js (build_clothing.js):**
```javascript
scanFolders: [
    'ef_clothes',
    'ef_clothes_new',
    // Add your custom folders here
]
```

**Python (build_clothing.py):**
```python
'scan_folders': [
    'ef_clothes',
    'ef_clothes_new',
    # Add your custom folders here
]
```

### Debug Mode

Enable debug mode in `client.lua`:
```lua
local DEBUG_MODE = true  -- Set to true for detailed logging
```

## 🔍 Troubleshooting

### Common Issues

**1. Floating Torsos / Head Only Showing**
- Ensure all clothing components are properly indexed
- Check that YTD textures match YDD drawables
- Verify component IDs in metadata

**2. Clothing Not Appearing**
- Run `/clothinginfo` to check build status
- Ensure resource is started after illenium-appearance
- Check console for error messages

**3. Build Errors**
- Check file permissions in clothing folders
- Ensure no files are locked/in use
- Verify folder structure matches expected format

**4. Performance Issues**
- Large clothing packs may cause longer loading times
- Consider splitting very large packs
- Monitor server performance after adding clothing

### Error Codes

- **Error 001**: Clothing folder not found
- **Error 002**: Invalid metadata format
- **Error 003**: Duplicate file conflict
- **Error 004**: Permission denied
- **Error 005**: Invalid file format

## 🤝 Integration

### With illenium-appearance

The system automatically integrates with illenium-appearance:

```lua
-- Automatic integration - no configuration needed
if GetResourceState('illenium-appearance') == 'started' then
    -- Clothing validation and application
end
```

### With QBX Core

Works seamlessly with QBX Core's character system:

```lua
-- Character creation integration
RegisterNetEvent('qbx_core:client:appearanceCompleted', function()
    -- Clothing system is ready
end)
```

## 📊 Build Reports

After each build, detailed reports are generated:

- `build_info.json` - Machine-readable build data
- `build_report.txt` - Human-readable summary

Example build report:
```
Files Processed: 1,247
Clothing Items: 1,198
Meta Files: 49
Duplicates Removed: 23
Total Size: 156.7 MB
Build Time: 2,341ms
```

## 🔒 Permissions

Required ACE permissions:

```cfg
# In server.cfg
add_ace group.admin clothing.admin allow
add_ace identifier.license:YOUR_LICENSE clothing.admin allow
```

## 📝 License

This system is provided as-is for FiveM server development. Modify and distribute freely.

## 🆘 Support

For issues and support:

1. Check the build reports for errors
2. Enable debug mode for detailed logging
3. Verify all dependencies are installed
4. Ensure proper file permissions

## 🔄 Updates

To update the system:

1. Replace the resource files
2. Run a rebuild: `/rebuildclothing`
3. Restart the resource: `restart clothing_loader`

---

**Made for FiveM • QBX Core • illenium-appearance**
