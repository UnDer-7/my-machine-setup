# ==================================================================================== #
# VARIABLES
# ==================================================================================== #
ANSIBLE_PLAYBOOK := playbook.yml
INVENTORY := inventory
VENV_DIR := .venv
ANSIBLE := $(VENV_DIR)/bin/ansible-playbook





# ==================================================================================== #
## ===== HELPERS =====
# ==================================================================================== #
## help: Describe all available targets
.PHONY: help
help:
	@echo 'Usage: make <target>'
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' | \
	awk 'BEGIN {first=1} /^ *=====/ { if (!first) print ""; print "   " $$0; first=0; next } { print "   " $$0 }'

## all: default target, shows help
.PHONY: all
all: help





# ==================================================================================== #
## ===== ANSIBLE =====
# ==================================================================================== #
## install-dep: Install Python, virtualenv, pip and Ansible in a venv
.PHONY: install-dep
install-dep:
	@echo ">>> Installing system packages for Python and venv..."
	if command -v apt-get >/dev/null; then \
	  sudo apt-get update && \
	  sudo apt-get install -y python3 python3-venv python3-pip; \
	elif command -v pacman >/dev/null; then \
	  sudo pacman -Sy --noconfirm python python-virtualenv python-pip; \
	else \
	  echo "Unsupported package manager. Please install Python3, pip, virtualenv manually." >&2; exit 1; \
	fi
	@echo ">>> Creating virtual environment at $(VENV_DIR)..."
	python3 -m venv $(VENV_DIR)
	@echo ">>> Installing Ansible into venv..."
	$(VENV_DIR)/bin/pip install --upgrade pip ansible

## up: Run the Ansible playbook against localhost
.PHONY: up
up:
	@echo ">>> Executing playbook $(ANSIBLE_PLAYBOOK) on localhost..."
	$(ANSIBLE) -i $(INVENTORY) $(ANSIBLE_PLAYBOOK) -c local
