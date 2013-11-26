#!/bin/bash

color_col="0;31"
color_heading="0;33"
color_list="0;37"

colorize() {
  tabs 6
  local heading="$(echo -e "$1" | head -1)"
  local content="$(echo -e "$1" | tail -n +2)"
  echo -e "\033[${color_col}m${heading}\033[0m"
  echo -e "\033[${color_list}m$content\033[0m"
}
heading() {
  local title=$1
  echo
  echo -e "\033[${color_heading}m$title"
  printf %80s |tr ' ' '='
  echo -e "\033[0m"
}
pad() {
  local length="$1"
  local left="$2"
  local right="${3}"
  local pad=$(printf '%0.1s' " "{1..40})
  echo -en "$left"
  printf '%*.*s' 0 $(( $length - ${#left} - ${#right})) "$pad"
  echo -en "$right"
}

########

cpu() {
  top -bn2 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%*\s*id.*/\1/" | awk '{print 100 - $1"%"}' | tail -1
}
process() {
  colorize "$(ps -eo pcpu,pmem,pid,user,args --columns 80 --sort -$1 | head -n 11)"
}
memory() {
  cat /proc/meminfo
}
ip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}
general() {
  (
    local cpu_usage=$(cpu)
    local ip=$(ip)
    echo -e "$(pad 27 "Hostname:" "$HOSTNAME")"
    echo -e "$(pad 27 "IP:" "$ip")"
    echo -e "$(memory)"
    echo -e "$(pad 27 "CPU usage:" "$cpu_usage")"
  ) | GREP_COLORS="mt=${color_col}:sl=${color_list}" \
      grep --color=auto '^[Mem|Swap]*[Free|Total]*[CPU usage|IP|Hostname]*:' 
}
zombie() {
  colorize "$(ps -eo stat,pcpu,pid,user,start,args --columns 80 | egrep '^STAT|Z' | grep -v egrep)"
}
disk() {
  colorize "$(df -h)"
}
ports() {
  local ports="$(netstat -lntup 2>/dev/null | awk 'NR == 1 || $6 == "LISTEN" { sub(/.*:/, "", $4); print $4 "/" $1 "\t\t" $7 }' | tail -n +2)"
  colorize "PORT\t\t\tAPPLICATION\n$ports"
}

is_running() {
  ps aux | grep -E "^${2:-root}.*${3:-/usr/sbin/$1}" > /dev/null
  [[ $? -eq 0 ]] && echo "1" || echo "0"
}
services() {
  declare -A services
  services[apache]=$(is_running "(apache2|httpd)")
  services[sshd]=$(is_running "sshd")
  services[varnishd]=$(is_running "varnishd")
  services[pound]=$(is_running "pound" "www-data")
  services[ufw]=$(status ufw | grep '^ufw start/running' >/dev/null && echo "1" || echo "0")
  services[cron]=$(is_running "cron" "root" "cron")
  services[mysql]=$(is_running "mysqld" "mysql")
  services[postfix]=$(is_running "postfix" "root" "/usr/lib/postfix/master")
  services[rsyslogd]=$(is_running "rsyslogd" "syslog" "rsyslogd")
  services[newrelic-daemon]=$(is_running "newrelic-daemon", "root" "/usr/bin/newrelic\-daemon")
  services[newrelic-sysmond]=$(is_running "nrsysmond" "newrelic")
  services[ntpd]=$(is_running "ntpd" "ntp")
  services[vnstat]=$(is_running "vnstat")
  local status=
  local running=

  for service in "${!services[@]}"; do
    running="${services[$service]}"
    ((running)) && status="\033[0;32mrunning\033[0m" || status="\033[0;31mdown\033[0m"
    echo -e "\033[${color_list}m$(pad 50 "$service" "$status")"
  done
}


heading "General"
general

heading "Disk space"
disk

heading "Services running"
services

heading "Open ports"
ports

heading "Top 10 | Process by CPU usage"
process "pcpu"

heading "Top 10 | Process by memory usage"
process "pmem"

heading "Zombie processes"
zombie
