# my-machine-setup

## Language rule — NEVER FORGET

**All code, comments, commit messages, documentation, and any written text in this project MUST be in English, ALWAYS.** No exceptions, regardless of what language the conversation happens in.

## What it is

Standalone CLI (compiled native via GraalVM) to automate new machine setup after a fresh Linux install/format. Usage flow:

1. User downloads the native executable (standalone binary, no need to install Java/runtime).
2. Runs `./my-machine-setup` (possibly with flags).
3. Program runs the machine install/configuration.
4. Finishes and exits — not a daemon, doesn't keep running in background.

## Supported distros

- Arch Linux
- Linux Mint
- macOS (planned for the future, don't implement yet unless asked)

## What the program does

1. **Installs programs**: reads a config file (`programs.json` at project root) listing which programs to install and where to download each one from, per distro (official repo, AUR, flatpak, third-party repo, GitHub binary release, etc). This file's format is still changing/being refined — don't treat the current structure as final, and don't document its schema here.
2. **Configures the system**: besides installing programs, does configuration tasks — clone/apply dotfiles (repo: https://github.com/UnDer-7/my-dotfile-config), Plex configs, date/time format adjustments, etc. First phase of the project focuses only on installing programs via `programs.json`; extra configs come later (possibly as another external config file).

## Behavior requirements

- **Idempotent**: before installing a program, check if it's already installed. If yes, skip and log. If no, install.
- **Failure isolation**: if installing one program fails, it doesn't bring down the whole program — only that item fails, log the error, continue to the next ones.
- **Zero external dependency on target environment**: being native (GraalVM), runs on any supported Linux distro without needing to install a JVM, Maven, or anything else.

## Tech stack

- **Java + Maven**, no application framework.
- **No Spring** (neither Spring Boot nor Spring Native) — AOT overhead and complexity unnecessary for this CLI's scope.
- **Picocli** for command-line parsing (flags, subcommands). Use the annotation processor (`picocli-codegen`) to auto-generate reflection metadata for GraalVM native-image.
- **Dependency injection**: manual (wiring by hand in `main()`/bootstrap). No Guice/Spring (heavy reflection, requires extra native-image config). If the project grows a lot in dependency-graph complexity, consider Dagger 2 (compile-time, zero reflection) — don't introduce now, no need yet.
- **GraalVM native-image** to generate the final native binary.

## Folder structure (planned)

```
br.com.gorillaroxo
├── Main.java                      # picocli entrypoint
├── cli/                           # picocli commands/flags
├── os/                            # parse /etc/os-release → record Distro(family, id, codename)
├── config/                        # read/parse programs.json → model
├── model/                         # Program, InstallSpec, PackageRef (literal|resolver), Source (static-url|github-latest-release|json-api)
├── installer/
│   ├── InstallStrategy.java       # interface: isInstalled(Program), install(Program)
│   ├── PacmanInstaller.java
│   ├── AurInstaller.java
│   ├── AptInstaller.java
│   ├── AptRepoInstaller.java      # add repo (key+source list) + apt install, resolve PackageRef (literal or dynamic resolver via apt-cache search)
│   ├── FlatpakInstaller.java
│   ├── BinaryReleaseInstaller.java # resolve Source (static-url/github-latest-release/json-api) + extract archive + symlink + desktop-entry
│   └── InstallerRegistry.java     # type string → strategy impl
└── log/                           # simple logger, no external lib
```

No `type: "custom"`— every hardcoded case (e.g. nvidia-driver, jetbrains-toolbox) generalizes within an existing `type` by enriching the `package` field (literal or dynamic resolver, e.g. `apt-cache-pattern` to get latest version) and `source` field (literal, `github-latest-release`, or `json-api` with `json_path` to extract a URL from a nested JSON response). See `programs.json` for real examples (`nvidia-driver`, `jetbrains-toolbox`).

Distro detection: reads `/etc/os-release`. Family (arch-like vs debian-like) comes from `ID`. Real codename for third-party repos (PPA, docker, virtualbox etc) comes from `UBUNTU_CODENAME` (present in Linux Mint, points to Ubuntu base) or `VERSION_CODENAME` as fallback — don't hardcode a manual mapping table.

"Already installed" check: per package, not per binary in PATH — `pacman -Qi` (pacman/AUR), `dpkg -s` (apt/apt-repo), `flatpak list --app` (flatpak), file/symlink marker at `install_path` (binary-release).

## Current structure

- `pom.xml` — Maven build, still skeleton.
- `src/main/java/br/com/gorillaroxo/Main.java` — entry point, still placeholder/exploratory.
- `programs.json` — config of programs to install (format evolving, but already without `type: "custom"`).

## legacy_ansible/

Legacy Ansible code (old version of the project, before the migration to Java). Has its own `legacy_ansible/CLAUDE.md` with details of the Ansible architecture.

Goal of the current Java project is to migrate all functionality from this legacy Ansible.

**Rule: `legacy_ansible/` is read-only for consultation.** Never change anything inside it — use it only as reference to understand what needs migrating and to validate whether something was already migrated correctly.

Once the migration finishes (everything in `legacy_ansible/` has a functional Java equivalent), this folder will be deleted.
