--[[
    Chris Locks System
    Author: Chris Hepburn
    Description: Advanced player and business lock system for FiveM (Qbox / QB / OX compatible)
    Version: 1.0.0
]]

Locales = Locales or {}
Locales['en'] = {
    notify_locked = 'Door is locked.',
    notify_unlocked = 'Door unlocked.',
    notify_relocked = 'Door relocked.',
    notify_wrong_password = 'Incorrect password.',
    notify_missing_item = 'You need %s to unlock this door.',
    notify_missing_job = 'You are not authorized to open this door.',
    notify_missing_owner = 'You do not own this property.',
    notify_in_progress = 'Unlock attempt already in progress.',
    notify_invalid_lock = 'Lock does not exist.',
    notify_added = 'Lock %s created.',
    notify_removed = 'Lock %s removed.',
    notify_exists = 'Lock ID already exists.',
    notify_saved = 'Lock saved.',
    notify_no_locks = 'No locks registered.',
    notify_not_authorized = 'You are not authorized to use this command.',
    notify_debug_enabled = 'Lock debug enabled.',
    notify_debug_disabled = 'Lock debug disabled.',
    prompt_password_title = 'Door Access',
    prompt_password_placeholder = 'Enter access code...',
    prompt_password_submit = 'Unlock',
    prompt_password_cancel = 'Cancel',
    password_required = 'Password required.',
    command_usage_addlock = 'Usage: /addlock <id> <type> <args...>',
    command_usage_removelock = 'Usage: /removelock <id>',
    command_usage_listlocks = 'Locks: %s',
    command_usage_debug = 'Lock debug toggled: %s',
    log_unlock_success = 'Unlock success %s by %s',
    log_unlock_fail = 'Unlock failed %s by %s',
}
