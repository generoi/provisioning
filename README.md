> **Warning This project was never finished and has since been abandoned.**

Definitions
-----------

Guidelines for tasks
--------------------
- Must be idempotent (can run multiple times, without causing side effects)
- Always specify a `state` (`present`, `absent`)
- Remember permissions
- Tag properly so it can be filtered when useful
- Fill out all fields of the comment template and keep it updated (config
  params arent necessary if too many).
- Reuse the helper tasks (service, ufw, monit, logrotate, vhost, etc.)
- If possible use `creates` or `removes` for each `shell` and `command` action.
- Make action names as descriptive as possible. If possible specify
  files modified or variables used.
- Make sure subsequent runs will not trigger any `changed` or `failed` events.

Guidelines for jobs
-------------------
- Structured as playbooks.
- Doesn't have to be idempotent.
- Prompting is nice!

Tags
----

_The toplevel tag is only applicable within a role inclusion, meaning these are
most likely not available in jobs._

- apache
- apache-config
- apache-wildcard
- apache-mods
- apache-https

- user
- user-config
- user-admins
- user-regular
- user-managed
- user-dotfiles
- user-known-hosts
- user-permissions
- user-groups
- user-create (Create user)
- user-delete

- rsyslog
- rsyslog-config
- rsyslog-loggly

- pound
- pound-config
- certificate-combined

- postfix
- postfix-config

- common
- common-config
- common-ntp
- common-ipv6
- common-git
- common-terminfo
- service
- service-enable
- service-disable

- development
- development-afp
- development-ruby
- development-ruby-gems
- development-nodejs
- development-nodejs-npm
- development-vim
- development-mosh
- development-fasd
- development-git
- development-ag

- project
- project-shared (shared files folder)
- project-drupal
- project-drupal-permissions
- project-wordpress
- project-wordpress-permissions
- project-other (nor drupal or wordpress)

- security
- security-tiger
- security-common
- security-denyhosts
- security-unattended-upgrades
- security-rootkit
- security-sysctl

- ufw
- ufw-config

- vnstat
- vnstat-config

- varnish
- varnish-config

- wpcli
- wpcli-config

- php
- php-apc
- php-xhprof
- php-xdebug
- php-dev

- newrelic
- newrelic-config
- newrelic-sysmond
- newrelic-php

- monit
- monit-config
- monit-webui
- monit-mail

- mariadb
- mariadb-pma
- mariadb-config
- mariadb-user-delete
- mariadb-user-create
- mariadb-db-create

- logrotate

- drush
- drush-config
- drush-dev

- webui: Webinterfaces such as pma, apc, xdebug, xhprof.
- openvz: OpenVZ specific fixes.
- ansible: Ansible dependencies

Lint handlers
-------------
- lint rsyslog
- lint apache
- lint monit

Todo
----
- Tiger syslog entry?
- rkhunter: syslog -> authpriv.notice
