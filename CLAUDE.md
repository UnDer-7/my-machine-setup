# my-machine-setup

## O que é

CLI standalone (compilado nativo via GraalVM) pra automatizar setup de máquina nova depois de formatar/instalar Linux. Fluxo de uso:

1. Usuário baixa o executável nativo (binário standalone, sem precisar instalar Java/runtime).
2. Roda `./my-machine-setup` (possivelmente com flags).
3. Programa executa a instalação/configuração da máquina.
4. Termina e finaliza — não é daemon, não fica rodando em background.

## Distros suportadas

- Arch Linux
- Linux Mint
- macOS (planejado pro futuro, não implementar ainda a menos que peçam)

## O que o programa faz

1. **Instala programas**: lê arquivo de configuração (`programs.json` na raiz do projeto) que lista quais programas instalar e de onde baixar cada um, por distro (repo oficial, AUR, flatpak, repo de terceiros, binary release do GitHub, etc). O formato desse arquivo ainda está em mudança/refinamento — não considerar a estrutura atual como definitiva, e não documentar o schema aqui.
2. **Configura o sistema**: além de instalar programas, faz tarefas de configuração — clonar/aplicar dotfiles (repo: https://github.com/UnDer-7/my-dotfile-config), configs do Plex, ajuste de formato de data/hora, etc. Primeira fase do projeto foca só na instalação de programas via `programs.json`; configs extras entram depois (possivelmente como outro arquivo de config externo).

## Requisitos de comportamento

- **Idempotente**: antes de instalar um programa, verifica se já está instalado. Se sim, pula e loga. Se não, instala.
- **Isolamento de falha**: se a instalação de um programa falhar, não derruba o programa inteiro — falha só aquele item, loga o erro, continua pros próximos.
- **Zero dependência externa no ambiente alvo**: por ser nativo (GraalVM), roda em qualquer distro Linux suportada sem precisar instalar JVM, Maven, nem nada.

## Stack técnica

- **Java + Maven**, sem framework de aplicação.
- **Sem Spring** (nem Spring Boot, nem Spring Native) — overhead e complexidade de AOT desnecessários pra esse escopo de CLI.
- **Picocli** pra parsing de linha de comando (flags, subcomandos). Usar o annotation processor (`picocli-codegen`) pra gerar os metadados de reflection automaticamente pro GraalVM native-image.
- **Injeção de dependência**: na mão (wiring manual no `main()`/bootstrap). Sem Guice/Spring (reflection pesado, exige config extra de native-image). Se o projeto crescer muito em complexidade de grafo de dependências, considerar Dagger 2 (compile-time, zero reflection) — não introduzir agora, sem necessidade.
- **GraalVM native-image** pra gerar o binário nativo final.

## Estrutura de pastas (planejada)

```
br.com.gorillaroxo
├── Main.java                      # entrypoint picocli
├── cli/                           # comandos/flags picocli
├── os/                            # parse /etc/os-release → record Distro(family, id, codename)
├── config/                        # leitura/parse de programs.json → model
├── model/                         # Program, InstallSpec, PackageRef (literal|resolver), Source (static-url|github-latest-release|json-api)
├── installer/
│   ├── InstallStrategy.java       # interface: isInstalled(Program), install(Program)
│   ├── PacmanInstaller.java
│   ├── AurInstaller.java
│   ├── AptInstaller.java
│   ├── AptRepoInstaller.java      # add repo (key+source list) + apt install, resolve PackageRef (literal ou resolver dinâmico via apt-cache search)
│   ├── FlatpakInstaller.java
│   ├── BinaryReleaseInstaller.java # resolve Source (static-url/github-latest-release/json-api) + extrai archive + symlink + desktop-entry
│   └── InstallerRegistry.java     # type string → strategy impl
└── log/                           # logger simples, sem lib externa
```

Sem `type: "custom"` — todo caso hardcoded (ex: nvidia-driver, jetbrains-toolbox) generaliza dentro de um `type` existente enriquecendo os campos `package` (literal ou resolver dinâmico, ex: `apt-cache-pattern` pra pegar versão mais recente) e `source` (literal, `github-latest-release`, ou `json-api` com `json_path` pra extrair URL de resposta JSON aninhada). Ver `programs.json` pros exemplos reais (`nvidia-driver`, `jetbrains-toolbox`).

Detecção de distro: lê `/etc/os-release`. Família (arch-like vs debian-like) vem do `ID`. Codename real pra repositórios de terceiro (PPA, docker, virtualbox etc) vem de `UBUNTU_CODENAME` (presente no Linux Mint, aponta pra base Ubuntu) ou `VERSION_CODENAME` como fallback — não hardcode tabela de mapeamento manual.

Verificação de "já instalado": por pacote, não por binário no PATH — `pacman -Qi` (pacman/AUR), `dpkg -s` (apt/apt-repo), `flatpak list --app` (flatpak), marker de arquivo/symlink em `install_path` (binary-release).

## Estrutura atual

- `pom.xml` — build Maven, ainda skeleton.
- `src/main/java/br/com/gorillaroxo/Main.java` — entry point, ainda placeholder/exploratório.
- `programs.json` — configuração de programas a instalar (formato em evolução, mas já sem `type: "custom"`).

## legacy_ansible/

Código legado do Ansible (versão antiga do projeto, antes da migração pra Java). Contém `legacy_ansible/CLAUDE.md` próprio com detalhes da arquitetura Ansible.

Objetivo do projeto Java atual é migrar toda a funcionalidade desse Ansible legado.

**Regra: `legacy_ansible/` é somente consulta.** Nunca alterar nada dentro dela — usar só como referência pra entender o que precisa ser migrado e validar se algo já foi migrado corretamente.

Quando a migração terminar (tudo que existe em `legacy_ansible/` tiver equivalente funcional em Java), essa pasta será excluída.
