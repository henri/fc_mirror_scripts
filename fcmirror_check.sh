#!/bin/sh

# This script will attempt to check the fcmirror is running.
# If the fcmirror is not running then an email will attempt to be sent.

# This script is released under the MIT licence : 
# http://www.opensource.org/licenses/mit-license.php

# Enter the name of the FirstClass Mirror volume.
MIRRORVOLUMENAME="FCMIRROR_RAID"

# Enter the path name of the backup log file.
MIRRORCHECKLOG="/Volumes/${MIRRORVOLUMENAME}/fc_mirror_scripts/logs/fc_backup_mirror_check.log"

# Enter the path name of the sendEmail script
SENDEMAIL="/Volumes/${MIRRORVOLUMENAME}/fc_mirror_scripts/sendEmail-v1.56/sendEmail"

# Enter the email address(s) you would like to recive notifications regarding issuse with the mirror
EMAILTO="helpdesk@yourdomain.com, fc_admin@yourdomain.com"

# Enter the email address you would like such mail to be recived from.
EMAILFROM="helpdesk@yourdomain.com"

# Enter the name of the mail server which will send any alerts
EMAILSERVER="mail.yourdomain.com"

# Number of seconds to wait for FirstClass Mirror pause and continue
# commands to complete.
SLEEP=30

# Number of retries to verify if mirror pause and continue succeeded.
MAXRETRIES=10


GetFirstClassPathNames()
{
    # FirstClass Applications Folder
    FIRSTCLASSAPPS="/Library/FirstClass Server"
    
    # FirstClass Volumes Folder
    FIRSTCLASSVOLUMES="/Library/FirstClass Server/Volumes"
    
    FCPUTIL="${FIRSTCLASSAPPS}/fcputil"
    
    if [ ! -x "$FCPUTIL" ]; then
      echo "FATAL: The FCPUTIL was not found at ${FCPUTIL} or is not executable"
      return 1
    fi

     MIRRORPATH="${FIRSTCLASSVOLUMES}/${MIRRORVOLUMENAME}"

     if [ ! -d "$MIRRORPATH" ]; then
          echo "FATAL: The FirstClass Mirror was not found at ${MIRRORPATH}"
          return 1
     fi

     return 0
}

CheckMirroring()
{
    echo "Checking FirstClass Mirroring is Running." >> $MIRRORCHECKLOG
    "$FCPUTIL" mcheck >> $MIRRORCHECKLOG 2>> $MIRRORCHECKLOG
    rc=$?
    if [ $rc = 2 ]; then
        echo "FirstClass Mirroring is Active." >> $MIRRORCHECKLOG
         exit 0
    else
         echo "FirstClass Mirroring is Probably Not Active : Error Code ($rc)." >> $MIRRORCHECKLOG
	   NotifyViaEmail
         exit 1
    fi
    return $rc
}

NotifyViaEmail()
{
    "$SENDEMAIL" -t "$EMAILTO" -u "FIRSTCLASS MIRROR ERROR!" -m "The mirror on FirstClass server is not currently working and requires immediate attention." -f "$EMAILFROM" -s "$EMAILSERVER" -l $MIRRORCHECKLOG

}

GetFirstClassPathNames
if [ $? != 0 ]; then
     exit $?
fi

# Place Space and Date Line in log file.
echo '' >> $MIRRORCHECKLOG
date +%d%h%y' '%H:%M:%S': FirstClass Mirror ***MirrorCheck*** Initiated' >> $MIRRORCHECKLOG

# Check if FirstClass Mirrored Network Store exists.
if [ ! -d "$MIRRORPATH/fcns8001" ]; then
     date +%d%h%y' '%H:%M:%S': FirstClass Mirror not found!' >> $MIRRORCHECKLOG
     date +%d%h%y' '%H:%M:%S': Mirror is most likely not running as it is not able to be detected.' >> $MIRRORCHECKLOG
     NotifyViaEmail
fi

# Pause the FirstClass mirror and write the result to log file.
date +%d%h%y' '%H:%M:%S': Checking FirstClass Mirroring Status' >> $MIRRORCHECKLOG
CheckMirroring

