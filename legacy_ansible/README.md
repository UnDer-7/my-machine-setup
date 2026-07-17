# Machine Setup with Ansible

This Ansible project automates the setup of a new development machine. It's designed to be distro-agnostic, working on Debian/Ubuntu, Arch Linux, and potentially other distributions.

## Project Structure

```
machine-setup/
├── playbook.yml       # Main playbook file
├── hosts.ini          # Inventory file (localhost only)
└── roles/             # Roles directory
    ├── essentials/    # Essential tools (git, curl, etc.)
    ├── programming/   # Programming languages and tools
    ├── browsers/      # Web browsers
    └── zsh/           # ZSH shell configuration
```

## Roles

- **essentials**: Installs basic tools like git, curl, wget, vim, etc.
- **zsh**: Installs and configures ZSH shell with Oh My ZSH
- **programming**: (Placeholder) For installing programming languages and tools
- **browsers**: (Placeholder) For installing web browsers

## Usage

To run the playbook:

```bash
ansible-playbook -i hosts.ini playbook.yml
```

## Requirements

- Ansible installed on the control machine
- Sudo access on the target machine

## Customization

You can customize the playbook by:

1. Editing the `playbook.yml` file to include or exclude roles
2. Modifying the tasks in each role to suit your needs
3. Adding new roles for additional functionality

## Supported Distributions

- Debian/Ubuntu
- Arch Linux

The playbook uses Ansible facts to detect the distribution and apply the appropriate tasks.