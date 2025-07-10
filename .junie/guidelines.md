## machine-setup Guidelines

### 1. Project Context

* **Goal**: Bootstrap a single machine (fresh OS) into a fully-configured developer workstation.
* **Target host**: `localhost` (one machine only, via `-c local`).
* **Supported OS families**:

    * Debian/Ubuntu (uses `apt`)
    * Arch Linux (uses `pacman`)
* **Key idea**: Pure Ansible playbooks—no external scripts or control-node setups.

### 2. Inventory

```ini
[local]
localhost ansible_connection=local
```

* Only one group (`local`) and one host (`localhost`).
* We explicitly set `ansible_connection=local` to avoid SSH.

### 3. Execution Context & Facts

* At the top of every playbook:

  ```yaml
  - hosts: local
    gather_facts: yes
  ```
* Rely on `ansible_facts.os_family` and `ansible_facts.distribution` to branch tasks:

  ```yaml
  when: ansible_facts.os_family == 'Debian'
  ```

### 4. Modular Role Structure

Organize your repository under `roles/`:

```
machine-setup/
├── playbook.yml
└── roles/
    ├── essentials/
    ├── programming/
    ├── browsers/
    ├── zsh/
    └── ...
```

Each role should contain:

* `tasks/main.yml`
* (Optionally) `vars/`, `defaults/`, `handlers/`, `files/`, `templates/`

#### Example roles

* **essentials**
  Install core tools (e.g. `git`, `curl`, `unzip`).
* **programming**
  Java, Node.js, Maven, Docker CLI, etc.
* **browsers**
  Chrome, Firefox, etc.
* **zsh**
  `oh-my-zsh`, plugins, theme.

### 5. Idempotency & Modules

* **Always** use built-in modules (`ansible.builtin.apt`, `ansible.builtin.pacman`, `ansible.builtin.package`, `ansible.builtin.blockinfile`, etc.).
* Avoid raw shell unless strictly necessary.
* Example (idempotent file block):

  ```yaml
  - name: Add custom alias to .zshrc
    blockinfile:
      path: "{{ ansible_env.HOME }}/.zshrc"
      block: |
        # custom aliases
        alias ll='ls -lah'
  ```

### 6. Error Handling & Conditional Skips

* **Optional installs** can continue on failure:

  ```yaml
  - name: Install optional tool foo
    ansible.builtin.package:
      name: foo
      state: present
    ignore_errors: yes
    register: foo_install
  - name: Skip bar if foo failed
    ansible.builtin.debug:
      msg: "foo failed—skipping bar"
    when: foo_install is failed
  - name: Install bar (depends on foo)
    ansible.builtin.package:
      name: bar
      state: present
    when: foo_install is succeeded
  ```
* Always log failures/skips with `debug` or a custom handler.

### 7. Comments & Documentation

* Precede each task with a descriptive comment in plain language:

  ```yaml
  # Ensure zsh is installed (required for oh-my-zsh)
  - name: Install ZSH
    ansible.builtin.package:
      name: zsh
      state: present
  ```
* Where helpful, link to official docs:

  > See [Ansible Package module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html)

### 8. Naming Conventions

* Roles, variables and tasks in **snake\_case**.
* Playbook file: `playbook.yml` or `site.yml`.
* Inventory file: `hosts.ini` or `inventory.yml`.

### 9. Sample Playbook Skeleton

```yaml
---
- name: Bootstrap local developer machine
  hosts: local
  gather_facts: yes

  vars:
    java_version: "17"
    nodejs_version: "20"

  roles:
    - essentials
    - zsh
    - programming
    - browsers
```

* **Line-by-line**:

    1. `---`
    2. `name`: human-readable description of the play.
    3. `hosts`: target inventory group (`local`).
    4. `gather_facts`: collect OS/runtime details.
    5. `vars`: role-agnostic parameters.
    6. `roles`: ordered list of roles to include.

---

Use these guidelines as the **single source of truth** for structure, style and best practices in your `machine-setup` repository. They’ll help any AI or collaborator generate consistent, maintainable Ansible code.
