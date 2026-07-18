# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Ansible-based machine setup project that automates the configuration of development machines. It's designed to be distro-agnostic, supporting Debian/Ubuntu and Arch Linux systems.

## Common Commands

### Primary Operations
- `make bootstrap` - Run the main playbook to set up the local machine (requires sudo password)
- `make help` - Display all available make targets with descriptions

### Installation
- `make install-ansible/apt-based` - Install Ansible on apt-based distributions (Ubuntu, Debian, etc.)
- `make setup/apt-based` - Install Ansible and run bootstrap in one command

### Manual Ansible Execution
- `ansible-playbook playbook.yml -c local --ask-become-pass` - Direct playbook execution

## Architecture

### Project Structure
- `playbook.yml` - Main playbook that orchestrates role execution in specific order
- `roles/` - Individual configuration modules, each handling specific setup tasks
- `inventory/hosts.ini` - Defines localhost as the target (ansible_connection=local)
- `ansible.cfg` - Ansible configuration with local-specific settings
- `group_vars/all.yml` - Global variables shared across all roles

### Role Architecture
The project uses a modular role-based architecture executed in this order:
1. `update` - System updates
2. `zsh-install` - ZSH shell installation
3. `zsh-dotfiles` - ZSH configuration files
4. `zsh-themes` - ZSH theme setup
5. `zsh_plugins` - ZSH plugin installation
6. `essential_packages` - Core system packages (curl, wget, htop, etc.)
7. `essential_programs` - Desktop applications via multiple package managers

### OS Detection Pattern
The project uses `helper_os_task_locator` role for cross-distro compatibility:
- Detects distribution and OS family using Ansible facts
- Maps to specific task files in `roles/*/tasks/systems/`
- Normalizes distribution names (e.g., "Linux Mint" → "linux_mint")
- Falls back from specific distribution to OS family

### Package Management Strategy
`essential_programs` role demonstrates multi-package-manager approach:
- **Flatpak**: Cross-distro applications (Discord, Bitwarden, etc.)
- **Arch Linux**: AUR and official repositories
- **Debian/Ubuntu**: Custom repositories with GPG key management for third-party software

### Configuration Management
- Global variables in `group_vars/all.yml` (currently defines dotfile paths)
- Role-specific defaults in `roles/*/defaults/main.yml`
- Upstream codename mapping for Ubuntu-based distributions in role defaults

## Development Notes

### Adding New Roles
1. Create role directory structure under `roles/`
2. Use `helper_os_task_locator` for OS-specific tasks
3. Place OS-specific files in `tasks/systems/` subdirectory
4. Add role to `playbook.yml` in appropriate execution order

### Third-party Repository Pattern
For Debian-based systems, repositories are defined with:
- Repository URL and components
- GPG key management (ASCII and binary keyring files)
- Ubuntu codename mapping for derivative distributions

### Lint
- ALWAYS use the ansible lint project as guideline on best conventions. Site: https://ansible.readthedocs.io/projects/lint/
- Truthy value should be one of [false, true] | Truthy value should be one of [false, true] | Rule: yaml[truthy] <formatting,yaml>
- Use FQCN for builtin module actions (apt_repository). | Use `ansible.builtin.apt_repository` or `ansible.legacy.apt_repository` instead. (Check whether actions are using using full qualified collection names.) | Rule: fqcn[action-core] <formatting>
- ALWAYS write the play names and documentation in english
