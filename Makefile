# app custom Makefile

# Docker repo & image name without version
IMAGE    ?= superseriousbusiness/gotosocial
# Hostname for external access
APP_SITE ?= fedi.dev.lan
# App names (db/user name etc)
APP_NAME ?= gts

# PgSQL used as DB
USE_DB = yes

# Sample admin user data
ADD_USER = yes

# ------------------------------------------------------------------------------
# app custom config

IMAGE_VER       ?= latest

DCAPE_ROOT      ?= /opt/dcape/var

DATA_PATH        ?= $(APP_NAME)

DCAPE_GTS_UID   ?= 1000
DCAPE_GTS_GID   ?= 1000

CONTAINER_ID ?= $(APP_TAG)_app_1

# ------------------------------------------------------------------------------
# .env template (custom part)
# inserted in .env.sample via 'make config'
define CONFIG_CUSTOM
# ------------------------------------------------------------------------------
# app custom config, generated by make config
# db:$(USE_DB) user:$(ADD_USER)

# Path to /opt/dcape/var. Used only outside drone
DCAPE_ROOT=$(DCAPE_ROOT)

DATA_PATH=$(DATA_PATH)

endef

# ------------------------------------------------------------------------------
# Find and include DCAPE/apps/drone/dcape-app/Makefile
DCAPE_COMPOSE   ?= dcape-compose
DCAPE_MAKEFILE  ?= $(shell docker inspect -f "{{.Config.Labels.dcape_app_makefile}}" $(DCAPE_COMPOSE))
ifeq ($(shell test -e $(DCAPE_MAKEFILE) && echo -n yes),yes)
  include $(DCAPE_MAKEFILE)
else
  include /opt/dcape-app/Makefile
endif


## create user
user-add:
	@docker exec -it $(CONTAINER_ID) /gotosocial/gotosocial admin account create \
	  --username $(USER_NAME) \
	  --email $(USER_EMAIL) \
	  --password '$(USER_PASS)'

## promote user to admin
user-admin:
	@docker exec -it $(CONTAINER_ID) /gotosocial/gotosocial admin account promote --username $(USER_NAME)

## create file storage with perms
storage:
	@path=$(DCAPE_ROOT)/$(DATA_PATH) ; \
	[ -d $$path ] || sudo install -o $(DCAPE_GTS_UID) -g $(DCAPE_GTS_GID) -d $$path
