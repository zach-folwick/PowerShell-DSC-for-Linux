TOP = ../..
include $(TOP)/config.mak

CSHLIBRARY = micodec

SOURCES = \
	codecimpl.c \
	mofcodec.c \
	strings.c \
	instanceutil.c \
	mofserializer.c \
	buf.c \
	strset.c

INCLUDES = $(OMI)/common  $(OMI) $(TOP) $(TOP)/codec/common $(OMI)/nits/base  $(TOP)/codec/mof/parser

DEFINES = MI_CONST=

LIBRARIES = mi pal miapi base mofparser nitspal

include $(OMI)/mak/rules.mak

