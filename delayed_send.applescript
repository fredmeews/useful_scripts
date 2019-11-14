--BEGINNING OF SCRIPT
set theDelay to on run argv
delay 

tell application "Mail" to activate
tell application "System Events" to tell process "Mail"
set theMenu to menu "Mailbox" of menu bar 1
if enabled of menu item "Take All Accounts Online" of theMenu then
       click menu item "Take All Accounts Online" of theMenu
       return "All accounts are currently offline"
else
return "All accounts are currently online"
end if
end tell
--END OF SCRIPT