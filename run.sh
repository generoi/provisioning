#!/bin/bash

pushd "$(dirname "${BASH_SOURCE}")" > /dev/null

# Detect whether output is piped or not.
[[ -t 1  ]] && piped=0 || piped=1

# Defaults
args=()

# Default inventory
inventory="inventory/production"
#inventory="inventory/testing" # temp
# Testing inventory when --test is used
inventory_testing="inventory/testing"
version="v0.1"

die() { echo -e "$@"; exit 1; } >&2
stdout() { echo -en "$(sed -n 's/.*stdout": "\(.*\)",*$/\1/p')"; }
stderr() { echo -en "$(sed -n 's/.*stderr": "\(.*\)",*$/\1/p')"; } >&2
output() { echo "$@" | stdout; echo "$@" | stderr; }
is_host() { grep "^\[\?$1" $inventory > /dev/null; return $?; }
confirm() { read -p "$1 [y/N] "; [[ $REPLY =~ ^[Yy]$ ]]; }

usage() {
  local name="$(basname $0)"
  echo -n "$name [OPTION]... [FILE]...

Run ansible jobs available

Ansible flags:
  --start-at-task=START_AT      start at specified task
  --step                        step by step confirmation
  --list-hosts                  list all hosts that WOULD run
  --list-tasks                  list all tasks that WOULD be executed
  --limit=SUBSET                limit hosts to pattern, eg. development
  --extra-vars=EXTRA_VARS       eg. key=val key2=val2
  --diff                        show difference between file changes
  --check                       dont make changes, try to predict changes
  --sudo_user=SUDO_USER         default root
  --ask-pass                    ask for pass
  --ask-sudo-pass               ask for sudo pass
  --private-key=PRIVATE_KEY     use specified private key
  --skip-tags=TAGS              skip tasks with tag
  --tags=TAGS                   only run tasks with tag
  --user=REMOTE_USER            connect as this user (default: $USER)
  --inventory=INVENTORY_FILE    specify the inventory file
  -v, -vvv, -vvvv               verbose mode for debugging

Commands (ansible-playbook):
  User:
    user add <host>               interactively add a user for host
    user remove <host>            interactively remove a user for host

  Backup:
    backup <host>                 backup host
    backup db <host>              backup host database
    backup docroot <host>         backup host document root

  Secure:
    secure <host>                 run security check/configuration tasks
    secure permissions <host>     secure file permissions
    secure scan-exploits <host>   check for exploits on host

  Setup:
    setup <host>                  run setup script on host

  Misc:
    ssh <host>                    ssh into host
    status <host>

Internal flags:
  --test                        use the test inventory

  ...if not found, delegates to ad hoc commands (ansible)

Examples:
  $name backup all --step
  $name secure permissions mushbarf.com --ask-sudo-pass --user=genero

Ad hoc examples:
  $name -a '/usr/bin/ping'
  $name backup -m copy -a 'src=/etc/hosts dest=/tmp/hosts'
  $name mushbarf.com -m apt -a 'pkg=git state=latest'
  $name status all --sudo
"
}

# Ansible delegations
########################

# Process the arguments passed to ansible
ansible_args() {
  args=()

  while (($#)); do
    case $1 in
      # if inventory is specified, use that!
      -i) shift; inventory="$1" ;;
      --inventory=*) inventory="${1#*=}" ;;
      --inventory=*) inventory="${1#*=}" ;;
      # use the test inventory
      --test) inventory="$inventory_testing" ;;
      # pass through
      *) args+=("$1") ;;
    esac
    shift
  done
  args+=("--inventory=$inventory")
  echo "${args[@]}"
}

playbook() {
  local name="$1"; shift
  echo "Running: ansible-playbook ${name}.yml $(ansible_args "$@")"
  ansible-playbook ${name}.yml $(ansible_args "$@") --list-hosts

  if confirm "Are you sure you want to run on these hosts?"; then
    ansible-playbook ${name}.yml $(ansible_args "$@")
  fi
}

adhoc() {
  echo "Running: ansible $(ansible_args "$@")"
  ansible $(ansible_args "$@") --list-hosts
  if confirm "Are you sure you want to run on these hosts?"; then
    result="$(ansible $(ansible_args "$@"))"
    [[ $? -gt 0 ]] && die "$result"
    output "$result"
  fi
}

# Commands
###########################

user() {
  local command="$1"; shift
  local target="$2"; shift
  # ! is_host "$target" ]] && die "not a valid host: $target"

  case $command in
    add|create)
      playbook "user-create" --extra-vars="target=$target" "$@"
      ;;
    del|remove|delete)
      die "Unimplemented"
      ;;
    *) die "Unknown command: $FUNCNAME $command"; ;;
  esac
}

backup() {
  local command="$1"; shift
  local target="$2"; shift
  ! is_host "$target" && die "not a valid host: $host"

  case $command in
    db) playbook "backup" --step --limit="$target" --tags=db "$@" ;;
    docroot) playbook "backup" --step --limit="$target" --tags=docroot "$@" ;;
    *) playbook "backup" --step --limit="$target" "$command" "$@"
  esac
}

secure() {
  local command="$1"; shift
  local target="$2"; shift
  ! is_host "$target" && die "not a valid host: $host"

  case $command in
    db) playbook "backup" --step --limit="$target" --tags=db "$@" ;;
    docroot) playbook "backup" --step --limit="$target" --tags=docroot "$@" ;;
    *) playbook "backup" --step --limit="$target" "$command" "$@"
  esac
}

setup() {
  playbook "$@"
}

status() {
  [[ "$#" -eq 0 ]] && die "host required"
  adhoc -m script -a 'files/status.sh' "$@"
}

init() {
  local target="$1"; shift;
  ! is_host "$target" && die "not a valid host: $target"
  command -v sshpass >/dev/null || sudo apt-get install -y sshpass
  [[ $? != 0 ]] && die "sshpass is required, please install it"
  python -c "import simplejson as json" >/dev/null || sudo apt-get install -y python-simplejson
  [[ $? != 0 ]] && die "python-simplejson is required, please install it"

  export ANSIBLE_HOST_KEY_CHECKING=False
  playbook "create-ansible" -i inventory/new --extra-vars="target=$target" --ask-pass "$@"
  export ANSIBLE_HOST_KEY_CHECKING=True
}

# Commands arguments
##################################

command=$1; shift

case $command in
  user) user "$@" ;;
  backup) backup "$@" ;;
  setup) setup "$@" ;;
  secure) secure "$@" ;;
  ""|--help|-h|help) usage; exit 1;;
  status) status "$@" ;;
  init) init "$@" ;;
  *) adhoc "$@" ;;
esac

popd > /dev/null

# ssh-agent bash
# ssh-add ~/.ssh/id_rsa
# do ansible things
