#!/bin/bash
# Copyright 2019, Cray Inc. All Rights Reserved.
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Mount system filesystems
#--------------------------------------
baseMount

#======================================
# Activate services
#--------------------------------------
baseInsertService dracut_hostonly
baseInsertService ldmsd-bootstrap

#======================================
# Deactivate services
#--------------------------------------
baseRemoveService NetworkManager
baseRemoveService NetworkManager-wait-online

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

exit 0
