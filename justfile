# To install just on a per-project basis
# 1. Activate your virtual environemnt
# 2. uv add --dev rust-just
# 3. Use just within the activated environment

drive_uuid := "77688511-78c5-4de3-9108-b631ff823ef4"
user :=  file_stem(home_dir())
def_drive := join("/media", user, drive_uuid)
project := file_stem(justfile_dir())
local_env := join(justfile_dir(), ".env")


# list all recipes
default:
    just --list

# Install tools globally
tools:
    uv tool install twine
    uv tool install ruff

# Build the package
build:
    rm -fr dist/*
    uv build

# Install all the necessary software
install:
    uv venv --python 3.12
    uv pip install matplotlib astropy notebook TESS-IDA-TOOLS licatools
    uv run tess-ida-db --console schema create

# Launches the Jupyter notebook
run:
    uv run jupyter notebook

# Original list is 1 7 17 33 62 73 75 76 88 201 202 272 495 536 555 608 612 639 660 714 746 747 749 759 795 831 835 945 1134

# get the IDA files and transform them to ECSV
ida:
    #!/usr/bin/env bash
    set -exuo pipefail
    for i in 1 7 17 33 51 62 73 75 76 85 88 201 202 272 495 555 608 612 639 660 714 746 747 749 759 795 831 835 945 1134
    do
        uv run tess-ida-pipe --console --trace single -m 2025-04 -i ida -o ecsv -n stars${i} 
    done

# Backup .env to storage unit
env-bak drive=def_drive: (check_mnt drive) (env-backup join(drive, "env", project))

# Restore .env from storage unit
env-rst drive=def_drive: (check_mnt drive) (env-restore join(drive, "env", project))


# ========================= #
# QUCK COMMAND LINE TESTING #
# ========================= #


# =======================================================================

    

[private]
check_mnt mnt:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! -d  {{ mnt }} ]]; then
        echo "Drive not mounted: {{ mnt }}"
        exit 1 
    fi

[private]
env-backup bak_dir:
    #!/usr/bin/env bash
    set -exuo pipefail
    if [[ ! -f  {{ local_env }} ]]; then
        echo "Can't backup: {{ local_env }} doesn't exists"
        exit 1 
    fi
    mkdir -p {{ bak_dir }}
    cp {{ local_env }} {{ bak_dir }}
    cp *.ecsv {{ bak_dir }}
  
[private]
env-restore bak_dir:
    #!/usr/bin/env bash
    set -euxo pipefail
    if [[ ! -f  {{ bak_dir }}/.env ]]; then
        echo "Can't restore: {{ bak_dir }}/.env doesn't exists"
        exit 1 
    fi
    cp {{ bak_dir }}/.env {{ local_env }}
    cp {{ bak_dir }}/*.ecsv .
