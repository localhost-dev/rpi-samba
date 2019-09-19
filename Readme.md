
## Dockerized SMB for Raspberry Pi 4

This repository contains **Dockerfile** of a dockerized [Samba](https://wikipedia.org/wiki/Samba_(software)) based on a [Raspbian image](https://hub.docker.com/r/balenalib/rpi-raspbian/).

## How to start

### 1. Running container:
```
docker run -d --restart=always \
  -p 445:445 \
  -v /tmp:/share/data \
  --name smb-server localhostdev:rpi-samba \
  -uid "$(id -u)" \
  -gid "$(id -g)" \
  -u "foo:bar" \
  -s "Data:/share/data:rw:foo"
```
**Note:** Run this exact command to see if everything is working for you.
It will run `smb-server` container and share your `/tmp` directory for user / pass `foo / bar`

### 2. Connecting to SMB:
Google it: `Connecting to SMB on {Your OS}`

## Complex example

### 1. Real life example:

```
docker run -d --restart=always \
  -p 445:445 \
  -v /media/storage:/share/data \
  -v /media/alice:/share/private/alice \
  -v /media/bob:/share/private/bob \
  --name smb-server localhostdev:rpi-samba \
# Global storage configuration
  -u "storage:storage_password" \
  -s "Backups:/share/data/backups:rw:storage,alice" \
  -s "Documents:/share/data/documents:rw:storage" \
  -s "Photos:/share/data/photos:rw:storage" \
  -s "Guest:/share/data/others:rw:storage" \
# Alice private storage
  -u "alice:alice_password" \
  -s "Alice (Private):/share/private/alice:rw:alice" \
# Bob private storage
  -u "bob:bob_password" \
  -s "Bob (Private):/share/private/bob:rw:bob"
```

## Detailed explanation

### 1. Docker commands step-by-step:

* `-d` Runs docker container is detached mode

* `-p` Exposes port on host side from container `host_post:container_port`

* `-v` Mount volume from host side to container side `host_directory:container_directory`

* `--name` Name of the container that will be run

* `-uid` & `-gid` Sending host UID & GID for proper mapping between the processes running inside a container and the host

* `-u` adds user with given arguments:
	`{username}`: User name, simple as that
	`{password}`: User password

	Example: `-u "lorem:passw0rd"`
	**Note:** Add each user with separate `-u` argument.

* `-s` adds share with given arguments:
	`{share name}`: Name of share that will be shown to end user.
	`{share path}`: Path of the share inside the docker container
	`{permissions}`: For "read only" type `ro` for "read & write" type `rw`
	`{users}`: List of users that can access this storage (Separated by `,`)

	Example: `-s "Documents:/share/docs:rw:lorem,ipsum,dolor"`
	**Note:** Add each share with separate `-s` argument.

### Github

https://github.com/localhost-dev/rpi-samba
