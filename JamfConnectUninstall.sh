# !/bin/bash
# Matthew Ward
# Original: 2020.02.10
# Updated: 2020.09.10
# v.19

# This script is intended to disable and remove all Jamf Connect v1 & v2 components.
# Configuration Profiles will only be removed if they contain com.jamf.connect; If that portion of the script fails, please remove  manually.

#Validated macOS 10.12 - macOS 11 (Big Sir)

# Variables

SyncLA='/Library/LaunchAgents/com.jamf.connect.sync.plist'
VerifyLA='/Library/LaunchAgents/com.jamf.connect.verify.plist'
Connect2LA='/Library/LaunchAgents/com.jamf.connect.plist'

ConnectApp='/Applications/Jamf Connect.app/'
SyncApp='/Applications/Jamf Connect Sync.app/'
VerifyApp='/Applications/Jamf Connect Verify.app/'
ConfigApp='/Applications/Jamf Connect Configuration.app/'

EvaluationAssets='/Users/Shared/JamfConnectEvaluationAssets/'
ChromeExtensions='/Library/Google/Chrome/NativeMessagingHosts/'

# Find if there's a console user or not. Blank return if not.

consoleuser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# get the UID for the user

uid=$(/usr/bin/id -u "$consoleuser")
/bin/echo ''''
/bin/echo 'Console user is '"$consoleuser"', UID: '"$uid"''


# disable and remove LaunchD components

if [ -f "$SyncLA" ]; then
	/bin/echo ''''
    /bin/echo "Jamf Connect Sync Launch Agent is present. Unloading & removing.."
    /bin/launchctl bootout gui/"$uid" "$SyncLA"
    /bin/rm -rf "$SyncLA"
        else 
    /bin/echo "Jamf Connect Sync launch agent not installed"
fi

if [ -f "$VerifyLA" ]; then
	/bin/echo ''''
    /bin/echo "Jamf Connect Verify Launch Agent is present. Unloading & removing.."
    /bin/launchctl bootout gui/"$uid" "$VerifyLA"
    /bin/rm -rf "$VerifyLA"
        else 
    /bin/echo "Jamf Connect Verify launch agent not installed"
fi

if [ -f "$Connect2LA" ]; then
	/bin/echo ''''
    /bin/echo "Jamf Connect 2 Launch Agent is present. Unloading & removing.."
    /bin/launchctl bootout gui/"$uid" "$Connect2LA"
    /bin/rm -rf "$Connect2LA"
        else 
    /bin/echo "Jamf Connect 2 launch agent not installed"
fi

/bin/echo ''''

/bin/echo "Jamf Connect LaunchAgents removed"


# Reset the macOS authentication database to default

if [ -f "/usr/local/bin/authchanger" ]; 
    then
        /usr/local/bin/authchanger -reset
        /bin/echo ''''
        /bin/echo "Default macOS loginwindow has been restored"
        /bin/echo ''''
        /bin/rm /usr/local/bin/authchanger
        /bin/rm /usr/local/lib/pam/pam_saml.so.2
        /bin/rm -r /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle
        /bin/echo "Jamf Connect Login components have been removed"
        /bin/echo ''''
    else 
        /bin/echo "Jamf Connect Login not installed; can't delete"
fi

# Remove Jamf Connect Applications

if [ -d "$SyncApp" ]; then
    /bin/rm -rf "$SyncApp"
    else 
    /bin/echo "Jamf Connect Sync is not installed; can't delete"
fi

if [ -d "$VerifyApp" ]; then
    /bin/rm -rf "$VerifyApp"
        else 
    /bin/echo "Jamf Connect Verify is not installed; can't delete"
fi

if [ -d "$ConfigApp" ]; then
    /bin/rm -rf "$ConfigApp"
        else 
    /bin/echo "Jamf Connect Configuration is not installed; can't delete"
fi

if [ -d "$ConnectApp" ]; then
    /bin/rm -rf "$ConnectApp"
        else 
    /bin/echo "Jamf Connect 2 is not installed; can't delete"
fi

/bin/echo 'Jamf Connect Applications have been removed'
/bin/echo ''''

# Remove Jamf Connect Evaluation Assets

if [ -d "$EvaluationAssets" ]; 
    then
        /bin/rm -rf "$EvaluationAssets"
        /bin/echo "Jamf Connect Assets have been removed"
        /bin/echo ''''
    else 
        /bin/echo "Jamf Connect Assets not installed; can't delete"
fi

# Remove Jamf Connect Chrome Extensions

if [ -d "$ChromeExtensions" ]; 
    then
        /bin/rm -rf "$ChromeExtensions"
        /bin/echo "Jamf Connect Chrome extensions have been removed"
        /bin/echo ''''
    else 
        /bin/echo "Jamf Connect Chrome extensions not installed; can't delete"
fi


# Remove Jamf Connect Evaluation Profiles

profilesArray=()
for i in $(profiles list | grep -i com.jamf.connect | awk '{ print $4 }'); do
    profilesArray+=("$i")
done
counter=0
for i in "${profilesArray[@]}"; do
    let "counter=counter+1"
done
if [ $counter == 0 ]; then
    echo "There were 0 Jamf Connect Profiles found. Continuing..."
else
    echo "There were $counter Jamf Connect Profiles found.  Removing..."
fi
for i in "${profilesArray[@]}"; do
    echo "Removing the profile $i..."
    /usr/bin/profiles -R -p "$i"
done

/bin/echo ''''
/bin/echo "$counter Jamf Connect Profiles have been removed."
/bin/echo ''''

/bin/echo "All Jamf Connect components have been removed."
/bin/echo ''''


exit
