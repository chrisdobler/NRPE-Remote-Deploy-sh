#!/bin/bash
#
# NRPE-SETUP by Christopher Dobler 2015
#
# USAGE:  
#   nrpe-setup user@host

NAG_PLUG_LOC="/usr/lib64/nagios/plugins"

ssh $1 'bash -s' < ~/talents/nrpe-setup-remote.sh

echo "copying extended checker files"

scp ~/talents/scp_files/check_filesystem $1:$NAG_PLUG_LOC
scp ~/talents/scp_files/check_yum $1:$NAG_PLUG_LOC

ssh "$1" bash -c "'
	chmod +x $NAG_PLUG_LOC/check_filesystem
	chmod +x $NAG_PLUG_LOC/check_yum
	service nrpe restart
	'"