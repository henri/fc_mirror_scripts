#####################################
#######   fc_mirror_scripts    ######
#####################################

(C) 2011 Henri Shustak
Released Under the MIT license : 
http://www.opensource.org/licenses/mit-license.php
http://www.githib/henri/fc_mirror_scripts

Introduction
------------
This set of scripts is intended to assist you with making cold backups of the FC mirror. Before use each script will need to be edited so that the various variables are configured for your use of the script.

These scripts are for use on Mac OS X systems. Although they could be easily modified for use on other *NIX systems.

The scripts should be installed and run on a server running FirstClass (from OpenText).


fcmirror_check.sh
------------------

The fcmirror_check.sh script will check that the mirror is running. If there is a problem then an email alert will be dispatched using SendEmail.

If you make use of the fcmirror_check.sh script then you will probably want to schedule the script to run with a tool such as cron. You will also want to edit this script so that the correct emails address and other variables are listed.

Finally, you will want to download a copy of SendEmail and set the location of this utility within the script : http://caspian.dotconf.net/menu/Software/SendEmail/



fcmirror_pause.sh
------------------

The fcmirror_pause.sh script will attempt to pause the FC mirror. 



fcmirror_continue.sh
------------------

The fcmirror_pause.sh script will attempt to restart the FC mirror.


