.PHONY: all
all : build

include $(BUILD_HARNESS)/makerules/arch.mk

MOD_TYPE := ptx
SCM_SRC  := bg_double.cu \
	bg_single.cu \
	perfs_double.cu \
	perfs_single.cu \
	yy_double.cu \
	yy_single.cu

OUTDIR := .

include $(MAKE_INCLUDE_DIR)/Makefile.module
