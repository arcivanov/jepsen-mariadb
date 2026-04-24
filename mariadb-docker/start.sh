#!/bin/bash
set -euo pipefail

NPROC=$(nproc --all)
MARIADB_DIR=~/mariadb-bin

create_build_tree_shim() {
    local src=$1
    local shim=~/mariadb-shim
    mkdir -p "$shim/bin" "$shim/scripts" "$shim/lib/plugin" "$shim/data"
    ln -sf "$src/sql/mariadbd" "$shim/bin/mariadbd"
    ln -sf "$src/scripts/mariadbd-safe" "$shim/bin/mariadbd-safe"
    ln -sf "$src/client/mysqladmin" "$shim/bin/mysqladmin"
    ln -sf "$src/extra/my_print_defaults" "$shim/bin/my_print_defaults"
    ln -sf "$src/extra/resolveip" "$shim/bin/resolveip"
    ln -sf "$src/extra/resolve_stack_dump" "$shim/bin/resolve_stack_dump"
    ln -sf "$src/extra/mariadbd-safe-helper" "$shim/bin/mariadbd-safe-helper"
    ln -sf "$src/scripts/mariadb-install-db" "$shim/scripts/mariadb-install-db"
    find "$src/plugin" "$src/storage" -maxdepth 2 -name '*.so' -type f \
        -exec ln -sf {} "$shim/lib/plugin/" \;
    ln -sf "$src/share" "$shim/share"
    MARIADB_DIR=$shim
}

if [ $# -gt 0 ]; then
    REPO=$1
    COMMITTISH=${2:-}

    cd ~
    if [ -n "$COMMITTISH" ]; then
        git clone "$REPO" --branch "$COMMITTISH" --depth 1 server
    else
        git clone "$REPO" --depth 1 server
    fi

    cmake -S server -B build \
        -DPLUGIN_{ARCHIVE,TOKUDB,MROONGA,OQGRAPH,ROCKSDB,CONNECT,SPIDER,SPHINX,COLUMNSTORE,PERFSCHEMA,XPAND}=NO \
        -DWITH_SAFEMALLOC=OFF \
        -DCMAKE_BUILD_TYPE=RelWithDebinfo \
        -DCMAKE_INSTALL_PREFIX="$MARIADB_DIR"
    cmake --build build -j"$NPROC"
    cmake --install build
    rm -rf ~/server ~/build
elif [ -f "$MARIADB_DIR/sql/mariadbd" ]; then
    create_build_tree_shim "$MARIADB_DIR"
fi

if [ ! -f "$MARIADB_DIR/bin/mariadbd" ]; then
    echo "Error: mariadbd not found at $MARIADB_DIR/bin/mariadbd" >&2
    echo "Usage:" >&2
    echo "  Clone & build:    docker run mariadb-jepsen <repo-url> [committish]" >&2
    echo "  Prebuilt install: docker run -v /path/to/install:/home/mariadb/mariadb-bin mariadb-jepsen" >&2
    echo "  Build tree:       docker run -v /path/to/build-tree:/home/mariadb/mariadb-bin mariadb-jepsen" >&2
    exit 1
fi

EXTRA_OPTS=""
if [ "$MARIADB_DIR" = "$HOME/mariadb-shim" ]; then
    EXTRA_OPTS="--mariadb-data-dir ${MARIADB_DIR}/data"
fi

export LEIN_OPTIONS="run test --db maria-docker --nodes localhost --concurrency ${NPROC} --rate 1000 --no-ssh=true --innodb-snapshot-isolation --mariadb-install-dir ${MARIADB_DIR} ${EXTRA_OPTS}"

cd ~/jepsen-mariadb
exec "${TEST_SCRIPT:-/tests.sh}"
