# LB Phone & Tablet - Quick Start Guide

## ✅ Current Status: Ready to Use (Minor Setup Required)

Both LB Phone and LB Tablet are installed and configured. Here's what you need to do:

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Import SQL Files (2 minutes)
**REQUIRED** - Import these SQL files into your database:
- `resources/[assets]/lb-phone/phone.sql`
- `resources/[assets]/lb-tablet/tablet.sql`

See `SQL_IMPORT_INSTRUCTIONS.md` for detailed instructions.

### Step 2: Configure API Keys (3 minutes)
**OPTIONAL** - But needed for photo/video uploads:

1. Sign up at [Fivemanage.com](https://fivemanage.com/) (use code `LBPHONE10` for 10% off)
2. Get your API keys
3. Edit these files:
   - `resources/[assets]/lb-phone/server/apiKeys.lua`
   - `resources/[assets]/lb-tablet/server/apiKeys.lua`
4. Replace `"API_KEY_HERE"` with your actual keys

**Note**: Phone calls and messages work without API keys. Only photo/video uploads need them.

---

## ✅ What's Already Configured

- ✅ Resources installed and auto-loading
- ✅ Framework auto-detection (qbox)
- ✅ Database checkers enabled
- ✅ Items not required (players can use phone/tablet immediately)
- ✅ All dependencies loaded in correct order
- ✅ Integration with qbox framework

---

## 🎮 Default Keybinds

### LB Phone
- **Open Phone**: `F1`
- **Toggle Cursor**: `ALT` (default)

### LB Tablet  
- **Open Tablet**: `F5`
- **Toggle Cursor**: `ALT` (default)

---

## 📋 Testing Checklist

After setup, test these:

### Phone Features
- [ ] Open phone (F1)
- [ ] Create phone number
- [ ] Make/receive calls
- [ ] Send/receive messages
- [ ] Take photos (if API keys configured)

### Tablet Features
- [ ] Open tablet (F5)
- [ ] Access police app (if police job)
- [ ] Access ambulance app (if ambulance job)
- [ ] View dispatch notifications

---

## 📚 Full Documentation

- **Detailed Verification Report**: See `LB_PHONE_TABLET_VERIFICATION.md`
- **SQL Import Instructions**: See `SQL_IMPORT_INSTRUCTIONS.md`
- **Official Docs**: [docs.lbscripts.com](https://docs.lbscripts.com/)

---

## ⚡ Troubleshooting

### Resources won't start?
- Check server console for errors
- Verify `oxmysql` and `qbx_core` are loaded
- Check database connection in server.cfg

### Phone/Tablet won't open?
- Check keybinds (F1 for phone, F5 for tablet)
- Verify resources started without errors
- Check console for error messages

### Photos won't upload?
- Verify API keys are configured
- Check upload method in config (should be "Fivemanage")
- Check server console for upload errors

---

## 🎉 You're All Set!

After importing SQL and optionally configuring API keys, your phone and tablet systems are ready to go!

**Need Help?**
- Check the verification report for detailed status
- Review official documentation at docs.lbscripts.com
- Check server console for error messages

