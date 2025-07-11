# ==================================================================================== #
# VARIABLES
# ==================================================================================== #
ANSIBLE_PLAYBOOK := playbook.yml
INVENTORY        := inventory
ANSIBLE          := ansible-playbook





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
## install-dep/ubuntu:: Install Ansible on Ubuntu via official PPA
.PHONY: install-dep/ubuntu:
install-dep/ubuntu:
	@echo ">>> Installing Ansible on Ubuntu via PPA…"
	sudo apt update
	sudo apt install -y software-properties-common
	sudo add-apt-repository --yes --update ppa:ansible/ansible
	sudo apt update
	sudo apt install -y ansible
	@echo ">>> Finished installing Ansible"

## up: Run the Ansible playbook against localhost
.PHONY: up
up:
	@echo ">>> Executing playbook $(ANSIBLE_PLAYBOOK) on localhost…"
	$(ANSIBLE) -i $(INVENTORY) $(ANSIBLE_PLAYBOOK) -c local
