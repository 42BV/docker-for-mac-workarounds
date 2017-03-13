#!/usr/bin/env bash

set -e

declare verbose
declare docker_database
declare docker_driver
declare flush_fix

log() {
  [[ ${verbose} ]] || return 0
  printf "=> $1\n" && return 0
}

error() {
  sleep 0.5
  printf "=> Error: $1\n" 1>&2 && exit 1
}

set_docker_database() {
  local user=$(id -un)
  local database="/Users/${user}/Library/Containers/com.docker.docker/Data/database"
  [[ -d ${database} ]] || error "Can't locate ${database}"
  docker_database="${database}"
  log "Set Database: ${docker_database}"
}

set_docker_driver() {
  [[ ${docker_database} ]] || error "Missing variable (docker_database)"
  local driver="${docker_database}/com.docker.driver.amd64-linux"
  [[ -d ${driver} ]] || log "Git Reset: $(cd "${docker_database}" && git reset --hard )"
  [[ -d ${driver} ]] || error "Can't locate ${driver}"
  docker_driver="${driver}"
  log "Set Driver: ${driver}"
}

disk_on_flush() {

  # The old disk/full-sync-on-flush is now replaced by the key disk/on-flush which takes the following values:
  # - os: use fsync to flush the buffers to the OS
  # - drive: use fcntl to flush the buffers to the drive
  # - none: do nothing on a flush

  [[ ${docker_driver} ]] || error "DOCKER_DRIVER not set"
  [[ "$1" ]] || error "Docker Setting: Missing argument: -f [os/drive/none]"
  local key=${docker_driver}/disk/on-flush
  local value=${1}
  local current=$(cat ${key})
  if [[ ! ${current} == ${value} ]]; then
    log "Current on-flush setting: ${current}"
    log "Updating to: ${value}"
    echo "${value}" > "${key}"
    log "Git add: ${key}$(cd "${docker_database}" && git add "${key}" )"
    log "Git commit: $(cd "${docker_database}" && git commit -m "Set ${key} from "${current}" to ${value}" )"
  else
    log "Current on-flush setting: ${current}"
  fi
  printf "Flush Fix ♥ from 42.nl\n"
}

usage() {
  printf "
  Usage: ${0} [options...]

  Options:
  -f [value]  Supported value's in preferred order:
              - none (do nothing on a flush)
              - ︎os (use fsync to flush the buffers to the OS)
              - drive (use fcntl to flush the buffers to the drive)
  -v          Verbose output
  -h          Show this help

  \n"
}

options() {
  [[ "$@" ]] || return 0
  local OPTIND=1
  while getopts "f:vh" OPTIND; do
    case $OPTIND in
      f) flush_fix=$OPTARG ;;
      v) verbose=1 ;;
      h) usage && exit 0 ;;
      *) usage && exit 1 ;;
    esac
  done
}

main() {
  options "$@"

  printf "Docker for Mac - Workarounds\n" && sleep 0.5
  set_docker_database
  set_docker_driver
  disk_on_flush "${flush_fix}"
}

main "$@"