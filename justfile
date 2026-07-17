# ====================================================================================
# VARIABLES
# ====================================================================================

project-name    := "my-machine-setup"
project-version := `grep -oPm1 '(?<=<version>)[^<]*' pom.xml`

# ====================================================================================
# DEFAULT
# ====================================================================================

[private]
default:
    @just --list

# ====================================================================================
# ALIASES
# ====================================================================================
alias c     := dev-compile
alias r     := dev-run

# ====================================================================================
# DEV
# ====================================================================================

# Clean all build outputs
[group: "dev"]
dev-clean:
    ./mvnw clean

# Compile the application
[group: "dev"]
dev-compile:
    @echo ">>> Compiling..."
    ./mvnw -B -ntp clean compile

# Build and run the application locally
[group: "dev"]
dev-run:
    ./mvnw clean compile exec:java

# ====================================================================================
# BUILD
# ====================================================================================

# Build GraalVM native image + bootJar in a single Gradle invocation
[group: "build"]
build-artifacts:
    #!/usr/bin/env bash
    ./mvnw -Pnative,fatjar clean package
    END=$(date +%s)
    ELAPSED=$((END-START))
    echo "Artifacts built in $((ELAPSED/3600))h $(((ELAPSED%3600)/60))m $((ELAPSED%60))s"

# Build the bootJar
[group: "build"]
build-jar:
    #!/usr/bin/env bash
    set -eo pipefail
    START=$(date +%s)
    ./mvnw clean package
    END=$(date +%s)
    ELAPSED=$((END-START))
    echo "bootJar built in $((ELAPSED/3600))h $(((ELAPSED%3600)/60))m $((ELAPSED%60))s"

# Build GraalVM native image
[group: "build"]
build-native:
    #!/usr/bin/env bash
    set -eo pipefail
    START=$(date +%s)
    ./mvnw -Pnative clean package
    END=$(date +%s)
    ELAPSED=$((END-START))
    echo "Native build completed in $((ELAPSED/3600))h $(((ELAPSED%3600)/60))m $((ELAPSED%60))s"

# ====================================================================================
# VERSION
# ====================================================================================

# Show current project version
[group: "version"]
version:
    @echo {{project-version}}

# Set project version (usage: just version-set 0.1.2)
[group: "version"]
version-set new-version:
    @./mvnw versions:set -DnewVersion={{new-version}} -DgenerateBackupPoms=false -q
    @echo "Version {{project-version}} → {{new-version}}"
