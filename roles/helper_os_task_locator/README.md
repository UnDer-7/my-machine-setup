# helper_os_task_locator

A helper role to locate and expose an OS-specific task file from a calling role’s `tasks/<subfolder>/` directory.
It looks for `<distribution>.yml` or `<os_family>.yml` (normalized to lowercase and underscores) and fails early if none are found.

## Requirements

None. This role only relies on built-in lookup plugins and facts gathered by Ansible.

## Role Variables

The caller can supply the following variables:

* **`include_dir`** *(string, optional)*
  : Subdirectory under `roles/<calling_role>/tasks/` where OS-specific files live. Defaults to `systems` as defined in `defaults/main.yml` if not provided.

* **`my_role_name`** *(string, required)*
  : The folder name of the calling role (e.g. `update`, `zsh-p10k`). Used to build the full path to the `tasks/<include_dir>/` directory.

Exposed variable after running:

* **`os_specific_file`** *(string)*
  : Full path to the first matching OS-specific file. Callers should use this in an `include_tasks`.

Normalization logic:

* Both distribution and os\_family facts are converted to **lower-case** and **spaces replaced by underscores**. For example:

  * `Linux Mint` → `linux_mint`
  * `RedHat`     → `redhat`

Files in `tasks/<include_dir>/` must be named accordingly, e.g.: `ubuntu.yml`, `linux_mint.yml`, `debian.yml`, `redhat.yml`.

## Dependencies

None.

## Example Directory Structure

```
roles/
└── helper_os_task_locator/
    ├── defaults/
    │   └── main.yml             # optional defaults (none required)
    └── tasks/
        └── main.yml             # this helper’s logic

roles/
└── update/
    └── tasks/
        ├── main.yml             # calls helper_os_task_locator
        └── systems/
            ├── debian.yml       # Debian/Ubuntu update tasks
            └── archlinux.yml    # Arch-specific update tasks
```

## Platform Specificity and Precedence

This helper supports both **generic** and **specific** OS tasks:

* A file named `<os_family>.yml` (e.g. `debian.yml`) will apply to all distributions in that family, such as Debian, Ubuntu, and Linux Mint.
* A file named `<distribution>.yml` (e.g. `linux_mint.yml`) will apply only to that exact distribution.

When locating a file, the helper uses the following order:

1. **Distribution** (`ansible_facts['distribution']`) — most specific match.
2. **OS Family** (`ansible_facts['os_family']`) — more generic fallback.

For example:

* `roles/update/tasks/systems/linux_mint.yml` will run only on Linux Mint.
* `roles/update/tasks/systems/debian.yml` will run on Debian, Ubuntu, and Linux Mint (if no `linux_mint.yml` exists).

## Example Playbook Usage

Here are two ways to use this helper:

1. **Using the default `include_dir` (`systems`):**

   ```yaml
   - hosts: localhost
     gather_facts: true

     roles:
       - role: update
         vars:
           # Determine OS-specific update file (uses default include_dir: systems)
           - name: Determine OS-specific update file
             ansible.builtin.include_role:
               name: helper_os_task_locator
             vars:
               my_role_name: update

           - name: Include OS-specific update tasks
             ansible.builtin.include_tasks:
               file: "{{ os_specific_file }}"
             become: true
   ```

2. **Using a custom `include_dir` (e.g. `font_setup`):**

   ```yaml
   - hosts: localhost
     gather_facts: true

     roles:
       - role: zsh-p10k
         vars:
           # Determine an OS-specific font setup file from custom folder
           - name: Determine OS-specific font setup file
             ansible.builtin.include_role:
               name: helper_os_task_locator
             vars:
               my_role_name: zsh-p10k
               include_dir: font_setup

           - name: Include OS-specific font setup tasks
             ansible.builtin.include_tasks:
               file: "{{ os_specific_file }}"
   ```

## License

BSD 3-Clause "New" or "Revised" License. See `LICENSE.txt` in this role for details.

## Author Information

Mateus Gomes da Silva Cardoso

* LinkedIn: [https://www.linkedin.com/in/mateus-gomes-da-silva-cardoso/](https://www.linkedin.com/in/mateus-gomes-da-silva-cardoso/)
* Email: [mateus7532@gmail.com](mailto:mateus7532@gmail.com)
