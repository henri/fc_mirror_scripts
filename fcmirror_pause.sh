#!/bin/sh

# This script will attempt to pause the fcmirror.

# Enter the name of the FirstClass Mirror volume.
MIRRORVOLUMENAME="FCMIRROR_RAID"


# Enter the path name of the backup log file.
BACKUPLOG="/Volumes/${MIRRORVOLUMENAME}/fc_mirror_scripts/logs/fc_backup_mirror_pause_continue.log"

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

PauseMirroring()
{
     echo "Pausing FirstClass Mirroring..." >> $BACKUPLOG
     "$FCPUTIL" pause >> $BACKUPLOG 2>> $BACKUPLOG
     rc=$?
     if [ $rc = 0 ]; then
          rc=1
          retries=1
          echo "Waiting $SLEEP seconds for command to complete..." >> $BACKUPLOG
          while [ $rc != 0 -a $retries -lt $MAXRETRIES ]; do
               sleep $SLEEP
             
               "$FCPUTIL" mcheck >> $BACKUPLOG 2>> $BACKUPLOG
               rc=$?
               if [ $rc = 0 ]; then
                    echo "FirstClass Mirroring Paused." >> $BACKUPLOG
               else
                    echo "FirstClass Mirroring Pause failed ($rc)." >> $BACKUPLOG
                    retries=`expr $retries + 1`
                    if [ $retries -lt $MAXRETRIES ]; then
                         echo "Waiting another $SLEEP seconds..." >> $BACKUPLOG
                    else
                         echo "Permanent failure" >> $BACKUPLOG
                    fi
               fi
          done
     else
          echo "Failed to pause FirstClass Mirroring ($rc)." >> $BACKUPLOG
     fi
     return $rc
}

GetFirstClassPathNames
if [ $? != 0 ]; then
     exit $?
fi

# Place Space and Date Line in log file.
echo '' >> $BACKUPLOG
date +%d%h%y' '%H:%M:%S': FirstClass Mirror ***Pause*** Initiated' >> $BACKUPLOG

# Check if FirstClass Mirrored Network Store exists.
if [ ! -d "$MIRRORPATH/fcns8001" ]; then
     date +%d%h%y' '%H:%M:%S': FirstClass Mirror not found!' >> $BACKUPLOG
     date +%d%h%y' '%H:%M:%S': Mirror was not able to be started.' >> $BACKUPLOG
     exit 1
fi


# Pause the FirstClass mirror and write the result to log file.
date +%d%h%y' '%H:%M:%S': Pausing FirstClass Mirroring' >> $BACKUPLOG
PauseMirroring
if [ $? != 0 ]; then
     exit $?
fi

exit 0

