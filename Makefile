# ==================================================================================== #
# VARIABLES
# ==================================================================================== #
ANSIBLE_PLAYBOOK := playbook.yml
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

# Hidden
.PHONY: all
all: help






# ==================================================================================== #
## ===== INSTALL ANSIBLE =====
# ==================================================================================== #
## install-ansible/apt-based: Install Ansible on apt-based distributions (Ubuntu, Debian, Linux Mint, ...)
.PHONY: install-ansible/apt-based
install-ansible/apt-based:
	@echo ">>> Installing Ansible via apt-based PPA…"
	sudo apt update
	sudo apt install -y software-properties-common
	sudo add-apt-repository --yes ppa:ansible/ansible
	sudo apt update
	sudo apt install -y ansible
	@echo ">>> Finished installing Ansible via apt-based PPA"
	ansible --version





# ==================================================================================== #
## ===== RUN ANSIBLE =====
# ==================================================================================== #
## bootstrap: Run the playbook to set up the local machine
.PHONY: bootstrap
bootstrap:
	@echo ">>> Bootstrapping local developer machine with playbook $(ANSIBLE_PLAYBOOK)…"
	@command -v ansible >/dev/null 2>&1 || { \
	  echo "Error: Ansible not installed, please run 'make install-ansible/{{your-package-manager}}' first"; \
	  exit 1; \
	}
	$(ANSIBLE) $(ANSIBLE_PLAYBOOK) -c local --ask-become-pass





# ==================================================================================== #
## ===== INSTALL AND RUN =====
# ==================================================================================== #
## setup/apt-based: Install Ansible on apt-based systems, then run bootstrap
.PHONY: setup/apt-based
setup/apt-based: install-ansible/apt-based bootstrap
