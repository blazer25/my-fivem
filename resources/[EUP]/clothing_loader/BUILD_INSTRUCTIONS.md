# EUP Build Instructions

## Current Status
- ✅ Build script updated to scan nested folders
- ⚠️ Female-EUP folder is empty (no clothing files)
- ⚠️ shop_ped_apparel.meta is empty and needs to be generated

## To Build EUP Clothing:

### Option 1: Run Build Script (Recommended)
1. Open a terminal/command prompt
2. Navigate to: `resources\[EUP]\clothing_loader\scripts`
3. Run one of these commands:
   - **Windows**: `build.bat`
   - **Linux/Mac**: `./build.sh`
   - **Node.js**: `node build_clothing.js`
   - **Python**: `python build_clothing.py`

### Option 2: Manual Build via Server Command
1. Start your FiveM server
2. Run in server console: `/rebuildclothing` (requires admin permissions)

## After Building:
1. Check `resources\[EUP]\clothing_loader\data\shop_ped_apparel.meta` - it should now have clothing entries
2. Restart the `clothing_loader` resource: `restart clothing_loader`
3. Restart `illenium-appearance` if needed: `restart illenium-appearance`

## Notes:
- Female-EUP folder is currently empty. If you have female EUP files, add them to that folder, or remove the folder if not needed.
- Male-EUP has files in a nested structure (`Male-EUP/stream/ef_clothes_new/stream/`) - the build script will scan these recursively.
- The build script processes files from: ef_clothes, ef_clothes_new, Male-EUP, Female-EUP, cfx_onx_gov_clothing, and ensart_sonsof

## Troubleshooting:
- If clothing still doesn't show, check the build report: `resources\[EUP]\clothing_loader\build_report.txt`
- Verify files were copied to: `resources\[EUP]\clothing_loader\stream\`
- Check server console for any errors from clothing_loader

