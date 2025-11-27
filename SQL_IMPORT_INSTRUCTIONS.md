# SQL Import Instructions for LB Phone and Tablet

## Quick Import Guide

You need to import SQL files to set up the database tables for LB Phone and Tablet.

---

## Option 1: Using phpMyAdmin or Database GUI Tool

1. Open your database management tool (phpMyAdmin, HeidiSQL, MySQL Workbench, etc.)
2. Select your database
3. Go to the "SQL" or "Import" tab
4. Copy and paste the contents of the SQL files, OR upload the files directly

**Files to import:**
- `resources/[assets]/lb-phone/phone.sql`
- `resources/[assets]/lb-tablet/tablet.sql`

---

## Option 2: Using MySQL Command Line

```bash
# Navigate to your FiveM server directory
cd "C:\Users\Local User\Desktop\my-fivem"

# Connect to MySQL (adjust credentials as needed)
mysql -u zap1339023-1 -p zap1339023-1

# Or use your full connection string
mysql -h mysql-mariadb-28-104-asx.zap-srv.com -u zap1339023-1 -p zap1339023-1

# Then import the files
source resources/[assets]/lb-phone/phone.sql
source resources/[assets]/lb-tablet/tablet.sql

# Exit MySQL
exit
```

---

## Option 3: Using FiveM Console (if your server supports it)

Some database tools allow importing through the FiveM console, but the above methods are more reliable.

---

## Optional SQL Files (Tablet Only)

These are optional features for the tablet:

- `resources/[assets]/lb-tablet/Optional SQL/conditions.sql` - For ambulance conditions system
- `resources/[assets]/lb-tablet/Optional SQL/offences.sql` - For police offences system  
- `resources/[assets]/lb-tablet/Optional SQL/registration.sql` - For registration app

**Import these only if you plan to use those features.**

---

## Verification

After importing, you can verify tables were created by checking for these key tables:

**LB Phone:**
- `phone_phones`
- `phone_phone_calls`
- `phone_message_channels`

**LB Tablet:**
- `lbtablet_tablets`
- `lbtablet_notifications`

---

## Notes

- The SQL files use `CREATE TABLE IF NOT EXISTS`, so running them multiple times is safe
- Both resources have database checkers enabled that can create missing tables automatically, but importing SQL is still recommended for initial setup
- Make sure you're importing to the correct database (check your `mysql_connection_string` in server.cfg)

