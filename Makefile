BUILD_PREFIX = usr/bin
.PHONY: all
all: build deploy-debian

include build_rules/templates/simple.mk
include build_rules/features/deploy/debian.mk
