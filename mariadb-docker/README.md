# MariaDB Jepsen Docker

Docker image for testing MariaDB transaction isolation with Jepsen.

## Building the Image

From the repository root:

```bash
docker build -t mariadb-jepsen -f mariadb-docker/Dockerfile .
```

## Running Tests

The entrypoint supports three modes, auto-detected based on arguments and
the contents of the mount point.

### Clone & Build Mode

Pass a MariaDB server git repository URL and an optional committish
(branch, tag, or SHA) to clone, build from source, and run all tests:

```bash
docker run mariadb-jepsen https://github.com/MariaDB/server 11.8
```

The committish is optional. If omitted, the repository's default branch is used:

```bash
docker run mariadb-jepsen https://github.com/MariaDB/server
```

### Prebuilt Install Mode

Mount a directory containing an installed MariaDB (standard prefix layout
with `bin/`, `scripts/`, `lib/plugin/`) and run with no arguments:

```bash
docker run -v /path/to/install:/home/mariadb/mariadb-bin mariadb-jepsen
```

### Build Tree Mode

Mount a cmake build tree directly (with `sql/mariadbd`, `client/mysqladmin`,
etc.) and run with no arguments. The entrypoint detects the build tree layout
and creates a symlink shim automatically:

```bash
docker run -v /path/to/build-tree:/home/mariadb/mariadb-bin mariadb-jepsen
```

## Test Scripts

After MariaDB setup, the entrypoint executes a test script controlled by the
`TEST_SCRIPT` environment variable. The default is `/tests.sh`.

### Full Suite (`/tests.sh`, default)

Runs the following workloads at multiple isolation levels:

- **append** at serializable, repeatable-read, read-committed, read-uncommitted
- **nonrepeatable-read** at serializable, repeatable-read
- **mav** at serializable, repeatable-read

### Verification (`/verify.sh`)

Runs a single short append test at serializable to validate that both MariaDB
and Jepsen are functional:

```bash
docker run -e TEST_SCRIPT=/verify.sh mariadb-jepsen https://github.com/MariaDB/server 11.8
```

All tests use `--innodb-snapshot-isolation` and run against a single local
MariaDB instance (no SSH, no nemesis).
