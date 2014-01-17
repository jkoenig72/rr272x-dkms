# $Id: Makefile,v 1.6 2009/12/11 00:47:48 wsw Exp $
#
# Copyright (C) 2013 HighPoint Technologies, Inc.
# All Rights Reserved.
#

HPT_ROOT := ../../..

C_DEFINES := -DSUPPORT_ARRAY 

TARGETNAME := rr272x_1x
TARGETTYPE := KMOD
TARGETMODS := him_rr272x.o ldm_raid50.o partition.o raid0.o raid1.o jbod.o raid5.o raid6.o
TARGETOBJS := os_linux.o osm_linux.o div64.o hptinfo.o config.o

include $(HPT_ROOT)/inc/linux_64mpa/Makefile.def

$(TARGETOBJS): osm_linux.h
