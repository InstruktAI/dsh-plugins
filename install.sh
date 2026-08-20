#!/bin/sh
# Link this checkout into $DSH_HOME, then install the plugins into every profile.
set -e

dsh_home="${DSH_HOME:-$HOME/.dsh}"
# The checkout is where this script lives, not where it was invoked from.
repo=$(cd "$(dirname "$0")" && pwd -P)

# ln -s follows a symlinked destination and creates the link *inside* it, which
# is how a self-referential $repo/dsh-plugins gets made. -n treats the symlink
# itself as the destination; -f then replaces it.
ensure_link() {
    target=$1
    source=$2
    if [ -L "$source" ]; then
        if [ "$(readlink "$source")" = "$target" ]; then
            return 0
        fi
    elif [ -e "$source" ]; then
        echo "refusing to replace $source: it exists and is not a symlink" >&2
        return 1
    fi
    ln -sfn "$target" "$source"
    echo "linked $source -> $target"
}

ensure_link "$repo" "$dsh_home/plugins"

sh "$dsh_home/plugins/dsh_install_plugins_all_profiles.sh"
